#!/usr/bin/env python3
"""
Extract author metadata from ODS files and generate structured CSV/JSON files.

Reads:
- 67_avtorov_rus.ods (67 authors with metadata)
- 98_avtorov_rus.ods (98 authors with metadata, expanded list)
- ART_pretest_merged_EN.xlsx (for item codes and author name matching)

Generates:
- Full CSV/JSON with all metadata fields
- Short version 1: excludes difficulty, literature_type, recognition_pattern
- Short version 2: excludes cult_status, narrative_complexity, stylistics

Requires: pandas, openpyxl, odfpy
Usage: python extract_author_metadata.py
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Optional

import pandas as pd


# Translation mapping for common Russian values to English
TRANSLATION_MAP = {
    "страна": {
        "русский": "russian",
        "зарубежный": "foreign"
    },
    "время": {
        "современный": "modern",
        "классический": "classic"
    },
    "уровень(1)": {
        "высокий": "high",
        "средний": "medium",
        "низкий": "low"
    },
    "уровень (2)": {
        "интеллектуальный": "intellectual",
        "классический": "classic",
        "массовый": "mass"
    },
    "уровень (3)": {
        "поиск": "search",
        "конвейер": "conveyor",
        "уровень": "level"
    },
    "культ": {
        "да": True,
        "yes": True,
        "нет": False
    },
    "жанр": {
        "художественный": "fiction",
        "детективный": "detective",
        "фантастический": "science_fiction",
        "приключенческий": "adventure",
        "исторический": "historical",
        "графический роман": "graphic_novel",
        "биография": "biography",
        "криминальный": "crime",
        "любовный роман": "romance",
        "подростковая литература": "young_adult"
    },
    "повествование(3)": {
        "сложное": "complex",
        "умеренное": "moderate",
        "простое": "simple"
    },
    "стилистика (3)": {
        "простая": "simple",
        "сдержанная": "restrained",
        "Изысканная": "refined"
    }
}

# Author name mapping (Russian -> English) - will be populated from xlsx
AUTHOR_NAME_MAP = {}


def normalize_value(value: str, field_name: str) -> any:
    """Normalize and translate Russian values to English."""
    if pd.isna(value) or value == "":
        return None
    
    value_str = str(value).strip()
    field_lower = field_name.lower()
    
    # Check translation map
    if field_lower in TRANSLATION_MAP:
        for ru_val, en_val in TRANSLATION_MAP[field_lower].items():
            if value_str.lower() == ru_val.lower():
                return en_val
    
    # Handle numeric fields
    if field_lower in ["год (mean publication year)", "период"]:
        try:
            return int(float(value_str))
        except (ValueError, TypeError):
            return None
    
    # Handle century field
    if field_lower == "век":
        # Normalize century notation
        value_str = value_str.replace("XX (вторая половина)", "XX-2")
        value_str = value_str.replace("XX (первая половина)", "XX-1")
        value_str = value_str.replace("XX (середина)", "XX-mid")
        return value_str
    
    # Return as-is if no translation found
    return value_str


def load_author_metadata_from_ods(ods_path: Path) -> Dict[str, Dict]:
    """Load author metadata from ODS file (transposed format)."""
    df = pd.read_excel(ods_path, engine='odf')
    
    # First column contains attribute names
    attributes = df.iloc[:, 0].tolist()
    # Remaining columns are authors
    author_columns = df.columns[1:].tolist()
    
    authors = {}
    
    for author_col in author_columns:
        author_name_ru = str(author_col).strip()
        if pd.isna(author_name_ru) or author_name_ru == "Unnamed: 0":
            continue
        
        author_data = {
            "name_ru": author_name_ru,
            "name_en": AUTHOR_NAME_MAP.get(author_name_ru, author_name_ru)
        }
        
        # Extract metadata for this author
        for idx, attr in enumerate(attributes):
            if pd.isna(attr) or str(attr).strip() == "":
                continue
            
            attr_name = str(attr).strip()
            value = df.loc[idx, author_col]
            
            # Skip the "Number" row
            if attr_name.lower() == "number":
                continue
            
            # Map attribute names to English field names
            field_mapping = {
                "Страна": "country",
                "Время": "time_period",
                "Год (mean publication year)": "publication_year",
                "Период": "decade",
                "Уровень(1)": "difficulty",
                "Уровень (2)": "literature_type",
                "Уровень (3)": "recognition_pattern",
                "Культ": "cult_status",
                "Жанр": "genre",
                "Повествование(3)": "narrative_complexity",
                "Стилистика (3)": "stylistics",
                "Век": "century"
            }
            
            en_field = field_mapping.get(attr_name, attr_name.lower().replace(" ", "_"))
            normalized_value = normalize_value(value, attr_name)
            
            if normalized_value is not None:
                author_data[en_field] = normalized_value
        
        authors[author_name_ru] = author_data
    
    return authors


def load_item_codes_from_xlsx(xlsx_path: Path) -> Dict[str, str]:
    """Load item codes and author names from xlsx file."""
    # Read first two rows: row 0 = labels, row 1 = codes
    df_labels = pd.read_excel(xlsx_path, engine='openpyxl', header=None, nrows=2)
    
    item_codes = {}
    author_names_en = {}
    
    # Row 0 has English author names, row 1 has item codes
    for col_idx in range(len(df_labels.columns)):
        author_name_en = str(df_labels.iloc[0, col_idx]).strip()
        item_code = str(df_labels.iloc[1, col_idx]).strip()
        
        # Skip non-author columns
        if col_idx < 5:  # Skip demographic columns
            continue
        
        # Skip fill items (foils)
        if item_code.startswith("fill") or pd.isna(item_code) or item_code == "nan":
            continue
        
        # Store mapping
        if author_name_en and author_name_en != "nan":
            item_codes[author_name_en] = item_code
            # Also try to match with Russian names (approximate)
            # This will be refined later
    
    return item_codes, author_names_en


def create_author_name_mapping(ods_authors: Dict, xlsx_item_codes: Dict) -> Dict[str, str]:
    """Create mapping between Russian and English author names."""
    # Manual mapping for known authors (can be expanded)
    manual_mapping = {
        "Донна Тартт": "Donna Tartt",
        "Габриель Гарсиа Маркес": "Gabriel Garsia Marquez",
        "Джеймс Фенимор Купер": "James Fenimore Cooper",
        "Генрик Сенкевич": "Henryk Sienkiewicz",
        "Джейн Остин": "Jane Austen",
        "Екатерина Вильмонт": "Catherine Vilmon",
        "Владимир Сорокин": "Vladimir Sorokin",
        "Евгений Водолазкин": "Evgeny Vodolazkin",
        "Валентин Распутин": "Valentin Rasputin",
        "Сергей Лукьяненко": "Sergey Lukyanenko",
        "Борис Васильев": "Boris Vasiliev",
        "Уильям Теккерей": "William Thackeray",
        "Виктор Ерофеев": "Victor Erofeev",
        "Василий Аксенов": "Vasily Aksyonov",
        "Аркадий Аверченко": "Arkady Averchenko",
        "Владимир Войнович": "Vladimir Voinovich",
        "Айзек Азимов": "Isaac Asimov",
        "Джордж Р.Р. Мартин": "George R.R. Martin",
        "Герман Мелвилл": "Herman Melville",
        "Михаил Веллер": "Mikhail Weller",
        "Ян Флеминг": "Ian Fleming",
        "Павел Санаев": "Pavel Sanaev",
        "Артур Хейли": "Arthur Haley",
        "Иван Ефремов": "Ivan Efremov",
        "Брэм Стокер": "Bram Stoker",
        "Джон Фаулз": "John Fowles",
        "Алексей Иванов": "Alexey Ivanov",
        "Генри Миллер": "Henry Miller",
        "Гузель Яхина": "Guzel Yakhina",
        "Шарлотта Бронте": "Charlotte Bronte",
        "Януш Вишневский": "Janusz Wisniewski",
        "Александра Маринина": "Alexandra Marinina",
        "Ирвин Уэлш": "Irwin Welch",
        "Татьяна Устинова": "Tatiana Ustinova",
        "Сомерсет Моэм": "Somerset Maugham",
        "Милорад Павич": "Milorad Pavic",
        "Марио Пьюзо": "Mario Puzo",
        "Анджей Сапковский": "Andrzej Sapkovski",
        "Мариам Петросян": "Mariam  Petrosyan",
        "Олдос Хаксли": "Aldous Huxley",
        "Дмитрий Глуховский": "Dmutry Gluhovsky",
        "Захар Прилепин": "Zakhar Prilepin",
        "Даниил Гранин": "Daniil Granin",
        "Чингиз Айтматов": "Chingiz Aitmanov",
        "Этель Лилиан Войнич": "Ethel Lilian Voynich",
        "Харпер Ли": "Harper Lee",
        "Дэн Браун": "Dan Bruwn",
        "Нил Гейман": "Neil Gaiman",
        "Ю Несбё": "Yu Nesbo",
        "Алан Мур": "Alane Moore",
        "Айн Рэнд": "Ayn Rand",
        "Ирвинг Стоун": "Irving Stone",
        "Леонид Андреев": "Leonid Andreev",
        "Илья Ильф": "Ilya Ilf",
        "Людмила Петрушевская": "Lyudmila Petrushevskaya",
        "Виктор Астафьев": "Victor Astafiev",
        "Дэниел Киз": "Daniel Keyes",
        "Виктор Пелевин": "Victor Pelevin",
        "Макс Фрай": "Max Fry",
        "Маргарет Митчелл": "Margaret Mitchell",
        "Сэмюэль Беккет": "Samuel Beckett",
        "Колин Маккалоу": "Colin McCullough",
        "Исаак Бабель": "Isaac Babel",
        "Томас Харди": "Thomas Hardy",
        "Маркус Зусак": "Markus Zusak",
        "Дина Рубина": "Dina Rubina",
        "Андрей Белянин": "Andrey Belyanin",
        "Людмила Улицкая": "Lyudmila Ulitskaya",
        "Арчибальд Кронин": "Archibald Cronin",
        "Джиллиан Флинн": "Gillian Flynn",
        "Пола Хокинс": "Paula Hawkins",
        "Джордж Оруэлл": "George Orwell",
        "Чарльз Диккенс": "Charles Dickens",
        "Наринэ Абгарян": "Narine Abgaryan",
        "Джоджо Мойес": "Jojo Moyes",
        "Джек Лондон": "Jack London",
        "Мари- Од Мюрей": "Marie - Aude Murai",
        "Артур Конан-Дойл": "Arthur Conan Doyle",
        "Джон Р.Р. Толкин": "John R.R. Tolkien",
        "Ли Бардуго": "Lee Bardugo",
        "Эрих Мария Ремарк": "Eric Maria Remarque",
        "Александр Дюма": "Alexandre Dumas",
        "Агата Кристи": "Agatha Christie",
        "Арт Шпигельман": "Art Spiegelman",
        "Рэй Брэдбери": "Ray Bradbury",
        "Харуки Мураками": "Haruki Murakami",
        "Кэтрин Скокетт": "Catherine Stokett",
        "Грегори Дэвид Робертс": "Gregory David Roberts",
        "Юстейн Гордер": "Yustein Gordier",
        "Борис Виан": "Boris Vian",
        "Фредерик Бакман": "Frederik Bucman",
        "Жуль Верн": "Jules Verne",
        "Мишель Холленбек": "Michel Houlleback",
        "Ришад Нури Гюнтекин": "Reshad Nuri Gyuntekin",
        "Лоуренс  Стерн": "Lawrense Stern",
        "Халед Хоссейни": "Khaled Hosseini",
        "Бернард Шоу": "Bernard Shaw",
        "Михаил Елизаров ": "Mikhail Elizarov"
    }
    
    return manual_mapping


def merge_author_data(ods_67: Dict, ods_98: Dict, item_codes: Dict, name_mapping: Dict) -> List[Dict]:
    """Merge data from both ODS files and add item codes."""
    # Use 98-author file as primary (more complete)
    all_authors = {}
    
    # Add authors from 98-author file
    for name_ru, data in ods_98.items():
        all_authors[name_ru] = data.copy()
    
    # Add any missing authors from 67-author file
    for name_ru, data in ods_67.items():
        if name_ru not in all_authors:
            all_authors[name_ru] = data.copy()
    
    # Add item codes and English names
    authors_list = []
    author_id = 1
    
    for name_ru, author_data in all_authors.items():
        name_en = name_mapping.get(name_ru, author_data.get("name_en", name_ru))
        
        # Find matching item code
        item_code = None
        for en_name, code in item_codes.items():
            # Try to match by English name (fuzzy)
            if name_en.lower() in en_name.lower() or en_name.lower() in name_en.lower():
                item_code = code
                break
        
        author_record = {
            "id": author_id,
            "name_en": name_en,
            "name_ru": name_ru,
            "item_code": item_code,
            "is_real": True,
            "metadata": {}
        }
        
        # Add metadata fields
        metadata_fields = [
            "country", "time_period", "publication_year", "decade",
            "difficulty", "literature_type", "recognition_pattern",
            "cult_status", "genre", "narrative_complexity", "stylistics", "century"
        ]
        
        for field in metadata_fields:
            if field in author_data:
                author_record["metadata"][field] = author_data[field]
        
        authors_list.append(author_record)
        author_id += 1
    
    return sorted(authors_list, key=lambda x: x["name_en"])


def save_csv(authors: List[Dict], output_path: Path, exclude_fields: List[str] = None):
    """Save authors to CSV format."""
    exclude_fields = exclude_fields or []
    
    rows = []
    for author in authors:
        row = {
            "id": author["id"],
            "name_en": author["name_en"],
            "name_ru": author["name_ru"],
            "item_code": author.get("item_code", ""),
            "is_real": author["is_real"]
        }
        
        # Add metadata fields (excluding specified ones)
        for field, value in author["metadata"].items():
            if field not in exclude_fields:
                row[field] = value
        
        rows.append(row)
    
    df = pd.DataFrame(rows)
    df.to_csv(output_path, index=False, encoding='utf-8')


def save_json(authors: List[Dict], output_path: Path, exclude_fields: List[str] = None):
    """Save authors to JSON format."""
    exclude_fields = exclude_fields or []
    
    output_data = {
        "authors": []
    }
    
    for author in authors:
        author_record = {
            "id": author["id"],
            "name": {
                "en": author["name_en"],
                "ru": author["name_ru"]
            },
            "item_code": author.get("item_code"),
            "is_real": author["is_real"],
            "metadata": {}
        }
        
        # Add metadata fields (excluding specified ones)
        for field, value in author["metadata"].items():
            if field not in exclude_fields:
                author_record["metadata"][field] = value
        
        output_data["authors"].append(author_record)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)


def main():
    """Main execution function."""
    # Paths: run from project root or scripts/data_prep/; project_root = repo root
    _script_dir = Path(__file__).resolve().parent
    project_root = _script_dir.parent.parent if _script_dir.name == "data_prep" else _script_dir.parent
    data_dir = project_root / "data" / "processed" / "author_metadata"
    data_dir.mkdir(parents=True, exist_ok=True)
    
    ods_67_path = project_root / "67_avtorov_rus.ods"
    ods_98_path = project_root / "98_avtorov_rus.ods"
    xlsx_path = project_root / "data" / "raw" / "ART_pretest_merged_EN.xlsx"
    
    print("Loading author metadata from ODS files...")
    ods_67_authors = load_author_metadata_from_ods(ods_67_path)
    ods_98_authors = load_author_metadata_from_ods(ods_98_path)
    
    print("Loading item codes from xlsx file...")
    item_codes, author_names_en = load_item_codes_from_xlsx(xlsx_path)
    
    print("Creating author name mapping...")
    name_mapping = create_author_name_mapping(ods_67_authors, item_codes)
    
    # Update global AUTHOR_NAME_MAP for use in load function
    global AUTHOR_NAME_MAP
    AUTHOR_NAME_MAP = name_mapping
    
    # Reload with proper name mapping
    print("Reloading with name mapping...")
    ods_67_authors = load_author_metadata_from_ods(ods_67_path)
    ods_98_authors = load_author_metadata_from_ods(ods_98_path)
    
    print("Merging author data...")
    authors = merge_author_data(ods_67_authors, ods_98_authors, item_codes, name_mapping)
    
    print(f"Found {len(authors)} authors")
    
    # Generate full versions
    print("\nGenerating full versions...")
    save_csv(authors, data_dir / "authors_metadata_full.csv")
    save_json(authors, data_dir / "authors_metadata_full.json")
    
    # Generate short version 1: exclude difficulty, literature_type, recognition_pattern
    print("Generating short version 1 (exclude: difficulty, literature_type, recognition_pattern)...")
    exclude_1 = ["difficulty", "literature_type", "recognition_pattern"]
    save_csv(authors, data_dir / "authors_metadata_short1.csv", exclude_fields=exclude_1)
    save_json(authors, data_dir / "authors_metadata_short1.json", exclude_fields=exclude_1)
    
    # Generate short version 2: exclude cult_status, narrative_complexity, stylistics
    print("Generating short version 2 (exclude: cult_status, narrative_complexity, stylistics)...")
    exclude_2 = ["cult_status", "narrative_complexity", "stylistics"]
    save_csv(authors, data_dir / "authors_metadata_short2.csv", exclude_fields=exclude_2)
    save_json(authors, data_dir / "authors_metadata_short2.json", exclude_fields=exclude_2)
    
    print(f"\nAll files saved to: {data_dir}")
    print("\nGenerated files:")
    print("  - authors_metadata_full.csv/json (all fields)")
    print("  - authors_metadata_short1.csv/json (exclude: difficulty, literature_type, recognition_pattern)")
    print("  - authors_metadata_short2.csv/json (exclude: cult_status, narrative_complexity, stylistics)")


if __name__ == "__main__":
    main()
