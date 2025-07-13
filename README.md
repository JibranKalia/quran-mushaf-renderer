# Quran Page Renderer

A lightweight Sinatra application for rendering Quran pages from SQLite database using data from the Quranic Universal Library (QUL).

## Credits and Attribution

This project uses data and resources from the **[Quranic Universal Library (QUL)](https://qul.tarteel.ai/)** by Tarteel AI. QUL is an incredible open-source project that provides comprehensive Quranic data including:

- Mushaf layouts for various printed editions
- Quranic text in multiple scripts
- Font files for accurate rendering
- Metadata about chapters and verses

All Quranic data, fonts, and layout information used in this application are sourced from QUL. We are deeply grateful for their efforts in making these resources freely available to the community.

## Features

- Renders authentic Quran pages matching printed mushafs
- Supports multiple mushaf types (Quran Complex V1, V2, Indopak)
- Uses page-specific fonts for accurate rendering
- Handles special elements like surah names and bismillah
- Right-to-left text support with proper justification
- Simple navigation between pages

## Prerequisites

- Ruby (version 2.5 or higher)
- SQLite3
- Bundler

## Installation

1. Clone this repository:

   ```bash
   git clone <repository-url>
   cd quran-page-renderer
   ```

2. Install dependencies:

   ```bash
   bundle install
   ```

3. Download the Quran database from QUL:
   - Visit [QUL Resources](https://qul.tarteel.ai/resources)
   - Download the required SQLite database with mushaf layouts and word data
   - Place the `quran-combined.db` file in the project root

## Database Structure

The application expects a SQLite database with the following tables:

- `mushaf` - Mushaf metadata (names, page counts, font codes)
- `mushaf_pages` - Page layout information (line types, word ranges)
- `words` - Quranic text with location data
- `chapters` - Surah information

## Usage

1. Start the application:

   ```bash
   ruby app.rb
   ```

2. Open your browser to <http://localhost:4567>

3. Navigate using the Previous/Next buttons or directly access pages:
   - `/mushaf/1/page/15` - Page 15 of Mushaf 1 (Quran Complex V1)
   - `/mushaf/2/page/15` - Page 15 of Mushaf 2 (Quran Complex V2)
   - `/mushaf/3/page/15` - Page 15 of Mushaf 3 (Indopak)

## Project Structure

```
.
├── app.rb                 # Main Sinatra application
├── Gemfile               # Ruby dependencies
├── quran-combined.db     # SQLite database (download from QUL)
└── views/
    ├── layout.erb        # HTML layout with fonts and styles
    └── page.erb          # Quran page rendering template
```

## Technical Details

### Fonts

The application uses web fonts hosted by QUL's CDN:

- Page-specific fonts for each mushaf type
- Special fonts for surah names and bismillah
- Fonts are loaded dynamically based on page number

### Rendering Logic

1. Queries the database for page layout information
2. Processes each line based on its type (ayah, surah_name, basmallah)
3. Fetches word data for ayah lines
4. Applies appropriate styling and fonts
5. Maintains proper text justification and alignment

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This rendering application is open source. However, please note:

- All Quranic data and fonts are provided by [QUL](https://qul.tarteel.ai/)
- Please refer to QUL's licensing terms for the data usage
- Always maintain proper attribution when using QUL resources

## Acknowledgments

Special thanks to the [Quranic Universal Library (QUL)](https://qul.tarteel.ai/) team at Tarteel AI for:

- Providing high-quality, open-source Quranic data
- Maintaining comprehensive mushaf layouts
- Hosting reliable font CDNs
- Supporting the global Muslim developer community

## Resources

- [QUL Website](https://qul.tarteel.ai/)
- [QUL Resources](https://qul.tarteel.ai/resources)
- [QUL Mushaf Layouts](https://qul.tarteel.ai/resources/mushaf-layout)
- [QUL Documentation](https://qul.tarteel.ai/docs)
