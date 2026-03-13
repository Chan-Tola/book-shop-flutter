lib/
├── core/ # Global constants, themes, and network configs
│ ├── api/ # Base API client (Dio or Http)
│ ├── constants/ # API endpoints, assets paths, strings
│ ├── theme/ # Dark Minimalism styling (colors, fonts)
│ └── utils/ # Shared validators, helpers
├── features/ # Logic grouped by business feature
│ ├── auth/ # Login, Register, Profile
│ │ ├── data/ # API calls & Models
│ │ ├── logic/ # State Management (Controllers/Blocs)
│ │ └── ui/ # LoginScreen, Widgets
│ ├── category/ # Genre listing & filtering
│ │ ├── data/
│ │ ├── logic/
│ │ └── ui/
│ ├── author/ # Author list & detail view
│ │ ├── data/
│ │ ├── logic/
│ │ └── ui/
│ └── book/ # The main shop, search, and details
│ ├── data/
│ ├── logic/
│ └── ui/
├── shared/ # UI components used across features
│ ├── widgets/ # Custom Buttons, Inputs, Book Cards
│ └── layouts/ # Main Navigation Wrapper (BottomNavBar)
└── main.dart # App Entry point
