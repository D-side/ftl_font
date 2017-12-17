# Инструменты обработки шрифтов FTL 1.6

* В папке `fonts` размещены исходные файлы шрифтов.
* В папке `destructured` размещены разобранные на компоненты шрифты
* В `lib` класс `FtlFont` для Ruby и все его составляющие, которые разбирают исходные файлы шрифтов на данные
* В `bin` несколько исполняемых (требуется Ruby, желательно 2.4) файлов:
    - `console` запускает REPL с загруженными инструментами
    - `destructure` преобразует файлы шрифтов в разобранные, для повторного разбора шрифта нужно предварительно уничтожить соответствующую папку в `destructured`

# Добавление новых символов

Процедура ещё не на 100% отработана. Чтобы добавить новый символ в разобранный шрифт, нужно

1. поместить файл PNG со строго чёрно-белым рисунком символа в соответствующую папку
2. добавить в файл `index.json` в этой папке запись о новом символе:

Было (в конце файла):

```json
  {
    "character": "ÿ",
    "baseline": 7,
    "png": "255.png"
  }
]
```

Стало (внимание, кроме объекта добавилась и запятая):

```json
  {
    "character": "ÿ",
    "baseline": 7,
    "png": "255.png"
  },
  {
    "character": "ы"
    "baseline": 7,
    "png": "ы.png"
  }
]
```

Важно использовать редактор, уважающий UTF-8. Блокнот не рекомендуется. Есть хороший и бесплатный [Atom](https://atom.io/)