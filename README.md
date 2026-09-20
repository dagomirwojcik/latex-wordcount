# LaTeX Word Count Utility

This repository contains a PowerShell script that estimates the word count of a LaTeX manuscript, with common thesis and dissertation boilerplate removed before counting.

It is intended for academic writing workflows where you want a quick, scriptable estimate for the body of a document without manually editing the source.

## What the script does

The script:

- reads `main.tex` from the same directory
- truncates content after chapter 8 if the document contains more than eight chapter headings
- removes title page, acknowledgements, abstract, glossary, table of contents, bibliography, and other front-matter content
- strips headings, citations, captions, labels, figure/table environments, and other LaTeX markup
- extracts list items from `enumerate` blocks
- removes comments and normalizes whitespace
- counts the remaining words
- reports figures, tables, and a combined total

## Requirements

- PowerShell 7+ (`pwsh`) or Windows PowerShell
- a file named `main.tex` in the repository root (or in the same folder where the script is executed)

## Usage

From the project directory, run:
```powershell
pwsh ./wordcount_script.ps1
```
On Windows PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File .\wordcount_script.ps1
```
The script prints output similar to:
```text
Regular words: 12345
Figures: 3
Tables: 2
Total word count: 12350
```

## Assumptions and caveats

This script is a practical estimator, not a complete LaTeX parser. It is designed around a typical thesis/dissertation workflow and intentionally ignores material that is usually not counted toward the body text, such as:

- title pages
- abstracts
- acknowledgements
- glossaries
- bibliographies
- chapter and section headings
- figure/table captions
- labels and citations
A few important caveats:
- It works best when the document uses standard LaTeX commands and environments.
- Some custom macros or non-standard authoring patterns may not be handled correctly.
- The final "Total word count" includes figures and tables in addition to regular words.
- Different universities or departments may define counting rules differently, so the result should be treated as an estimate.

## License

This project is distributed under the MIT License. See `LICENSE` for details.