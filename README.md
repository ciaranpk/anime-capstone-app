# Anime Favorites App

## Overview
Anime Favorites is a simple iOS app built with **Swift and UIKit** in Xcode. It lets users browse a list of anime, read information about each show, and save their favorites. I also added a Search tab, but the search feature is not fully working yet.

## Features
- **Anime List:** Browse anime titles in a table view.
- **Anime Details:** Tap an anime to see its title, description, and image.
- **Favorites:** Add or remove anime from a favorites list.
- **Saved Favorites:** Favorites are stored locally so they can be loaded again later.
- **Search Tab (In Progress):** A separate tab for searching anime has been added, but its functionality still needs work.

## Technologies Used
- Swift
- UIKit (not SwiftUI)
- Xcode and Storyboard
- UITableView and UINavigationController
- URLSession for downloading images and supporting API requests
- Codable and JSON for anime data and saved favorites
- FileManager for local storage

## How It Works
The app currently loads a small sample list of anime. Users can select a title to open its detail screen and add it to their favorites. The Favorites screen displays saved anime and allows users to remove them. The app uses a tab-based layout, with a Search tab that is still being developed.

The code also includes support for the **Jikan API** to retrieve anime information. However, the anime list currently calls `fetchAnimeList(useMock: true)`, so it uses sample data instead of making a live API request.

## How to Run
1. Open the project in Xcode.
2. Select an iPhone simulator.
3. Build and run the app.
4. Browse the anime list, open a detail page, and try adding an anime to Favorites.

## Current Limitations and Future Improvements
- Finish the Search tab so users can search for anime by name.
- Switch from sample data to live anime results using the Jikan API.
- Test the app's navigation, images, and favorites features more thoroughly.
- Improve the app's appearance and layout.

## What I Learned
This project helped me practice using Swift and UIKit to create an iOS app. I worked with table views, navigation between screens, passing anime data to a detail view, and saving favorites locally. I also learned how an app can be structured to retrieve information from an API. One challenge was getting the Search tab to work correctly, which is something I would like to finish in the future.
