# Images Folder

This folder contains image assets for the pizza shop application.

## Purpose

Stores product images, logos, icons, and other visual assets used throughout the application.

## Typical Contents

- **Pizza images** - Photos of pre-made pizzas (8-10 images)
- **Topping images** - Icons or photos of individual toppings
- **Logo** - Pizza shop branding logo
- **Background images** - Hero images or decorative elements
- **Icons** - Custom icons (if not using Font Awesome/Glyphicons)

## Image Specifications

### Pizza Product Images
- Format: JPG or PNG
- Recommended size: 400x400 px (square)
- Naming convention: `pizza-[name].jpg` (e.g., `pizza-margherita.jpg`)

### Topping Images
- Format: PNG with transparency
- Recommended size: 64x64 px or 128x128 px
- Naming convention: `topping-[name].png`

### Logo
- Format: PNG with transparency
- Sizes: Multiple sizes for different contexts
- Naming: `logo.png`, `logo-sm.png`

## Legacy Patterns to Note

### Direct File References
Images referenced directly in markup with hardcoded paths.

```html
<!-- LEGACY PATTERN: Hardcoded image paths -->
<asp:Image ImageUrl="~/Images/pizza-margherita.jpg" />

<!-- MODERNIZATION PATH: CDN or blob storage with dynamic URLs -->
```

### No Image Optimization
Images served as-is without optimization, lazy loading, or responsive variants.

```
LEGACY PATTERN: Full-size images loaded immediately
MODERNIZATION PATH: Responsive images, lazy loading, WebP format, CDN
```

### Local Storage Only
All images stored in application directory, not external storage.

```
LEGACY PATTERN: Images in application folder
MODERNIZATION PATH: Azure Blob Storage or CDN
```

## Placeholder Images

For initial development, placeholder images can be used:
- [Unsplash](https://unsplash.com) for pizza photos
- [Placeholder.com](https://placeholder.com) for temporary placeholders
- CSS-based placeholders for initial mockups

## Modernization Priority

**LOW** - Images can be migrated to cloud storage during modernization without code changes.

## Note for Development

Since this is a demonstration project, you may choose to:
1. Use placeholder images from external sources
2. Use CSS background colors as placeholders
3. Reference free pizza images from Unsplash/Pexels
4. Create simple SVG placeholders

The image structure and naming conventions are more important than actual image content for modernization demonstrations.
