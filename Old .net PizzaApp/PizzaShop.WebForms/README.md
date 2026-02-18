# PizzaShop.WebForms

A legacy ASP.NET Web Forms application demonstrating classic enterprise patterns for modernization scenarios.

## Overview

This is a fully functional pizza shop e-commerce application built with ASP.NET Web Forms 4.7.2. Users can browse a menu of pre-made pizzas, build custom pizzas with their choice of size, crust, and toppings, add items to a shopping cart, and complete a simulated checkout process.

The application is intentionally built with legacy patterns from the 2010s era to serve as a realistic modernization demonstration, showcasing how AI-assisted tools can help transform classic enterprise applications to modern .NET.

## Technology Stack

- **Framework**: .NET Framework 4.7.2
- **Platform**: ASP.NET Web Forms
- **UI Framework**: Bootstrap 3.3.7
- **JavaScript**: jQuery 2.2.4
- **Icons**: Font Awesome 4.7.0
- **Data Storage**: In-memory collections (simulated database)
- **State Management**: Server-side Session state (InProc mode)
- **AJAX**: UpdatePanel and ScriptManager

## Features

### 1. Home Page (Default.aspx)
- Hero section with call-to-action
- Featured pizzas carousel
- Navigation to menu and custom builder

### 2. Menu (Menu.aspx)
- Browse all pre-made specialty pizzas
- Filter by category (All, Vegetarian, Meat Lovers, Supreme)
- View pizza details (name, description, price)
- Add to cart with size selection
- Responsive grid layout

### 3. Build Your Own Pizza (BuildPizza.aspx)
- Choose pizza size (Small, Medium, Large)
- Select crust type (Original, Thin, Thick, Stuffed, Gluten-Free)
- Pick multiple toppings from 18 options
- Filter toppings by category (All, Meat, Vegetables, Cheese)
- Filter for vegetarian toppings only
- Real-time price calculation
- Dynamic pricing based on size and premium options

### 4. Shopping Cart (Cart.aspx)
- View all cart items
- Update item quantities
- Remove items
- Order summary with subtotal, tax, and delivery fee
- Empty cart state with call-to-action
- Continue shopping or proceed to checkout

### 5. Order Confirmation (Confirmation.aspx)
- Order number generation
- Estimated delivery time
- Complete order summary
- No-order-found state handling

## Project Structure

```
PizzaShop.WebForms/
├── Pages/              # Web Forms pages (.aspx)
│   ├── Default.aspx    # Home page
│   ├── Menu.aspx       # Pizza menu catalog
│   ├── BuildPizza.aspx # Custom pizza builder
│   ├── Cart.aspx       # Shopping cart
│   └── Confirmation.aspx
├── Models/             # Business entities
│   ├── Pizza.cs
│   ├── Topping.cs
│   ├── OrderItem.cs
│   └── Order.cs
├── Data/               # Data access layer
│   ├── PizzaRepository.cs
│   └── ToppingRepository.cs
├── Content/            # CSS styles
│   └── site.css
├── Scripts/            # JavaScript files
│   └── site.js
├── Properties/         # Assembly info
├── Site.Master         # Master page layout
├── Global.asax         # Application events
├── Web.config          # Configuration
└── *.csproj           # Project file
```

## Prerequisites

- **Visual Studio 2017** or later (2019/2022 recommended)
- **.NET Framework 4.7.2 Developer Pack** or later
- **IIS Express** (included with Visual Studio)
- **Web browser** (Chrome, Edge, Firefox)

## Setup Instructions

### Option 1: Visual Studio

1. **Clone or download** this repository
   
2. **Open the solution**
   ```
   Open PizzaShop.WebForms.csproj in Visual Studio
   ```

3. **Restore NuGet packages** (if prompted)
   - Right-click solution → Restore NuGet Packages
   - Note: This project uses GAC references, minimal NuGet dependencies

4. **Build the solution**
   ```
   Build → Build Solution (Ctrl+Shift+B)
   ```

5. **Run the application**
   ```
   Debug → Start Debugging (F5)
   or
   Debug → Start Without Debugging (Ctrl+F5)
   ```

6. **Application will open** at `http://localhost:54321/Pages/Default.aspx`

### Option 2: Command Line (MSBuild)

```powershell
# Navigate to project directory
cd path\to\PizzaShop.WebForms

# Build the project
msbuild PizzaShop.WebForms.csproj /p:Configuration=Release

# Note: Running requires IIS or IIS Express configuration
```

## Running the Application

### First Launch

1. Click **F5** in Visual Studio
2. IIS Express will start automatically
3. Browser opens to home page
4. Browse featured pizzas or navigate to:
   - **Menu** - View all pizzas
   - **Build Your Own** - Create custom pizza
   - **Shopping cart** - View cart (badge in header)

### Using the Application

#### Browse Pre-Made Pizzas
1. Click **Menu** in navigation
2. Select a category filter (optional)
3. Click **Add to Cart** for any pizza
4. Choose size (Small/Medium/Large)
5. Confirm addition

#### Build Custom Pizza
1. Click **Build Your Own**
2. Select size (affects price multiplier)
3. Choose crust type (premium crusts add cost)
4. Select toppings (each topping adds $1.50)
5. Click **Calculate Price** to see total
6. Click **Add to Cart**

#### Checkout
1. Click cart icon in header (shows item count)
2. Review items, update quantities
3. Click **Proceed to Checkout**
4. View confirmation page

## Legacy Patterns Demonstrated

This application showcases common legacy patterns documented with inline comments:

### Code-Behind Pattern
- Tight coupling between `.aspx` markup and `.aspx.cs` code
- Page lifecycle events (Page_Load, Page_PreRender)
- Direct server control manipulation

### ViewState
- Enabled globally in Web.config
- Automatic state preservation across postbacks
- Base64-encoded hidden field (__VIEWSTATE)

### Session State (InProc)
- Shopping cart stored in Session["Cart"]
- Server-side memory storage
- Non-scalable for web farms

### Postback Model
- Full page postbacks for server events
- AutoPostBack on controls (DropDownList)
- UpdatePanel for "AJAX" partial updates

### Server Controls
- Repeater, GridView for data binding
- RequiredFieldValidator, RangeValidator
- HyperLink, LinkButton controls

### Direct Database Access (Simulated)
- Static methods in repository classes
- Synchronous data access
- No dependency injection
- No interfaces/abstractions

### Global.asax
- Application_Start for initialization
- Session_Start for cart creation
- Application-wide event handling

## Modernization Path

This application is designed to be modernized to modern .NET. See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for full modernization roadmap.

### Target Modern Stack

```
.NET Framework 4.7.2    →    .NET 8+
ASP.NET Web Forms       →    Blazor Server or WASM
ViewState               →    Component state
Session (InProc)        →    Redis distributed cache
UpdatePanel             →    SignalR real-time updates
Server controls         →    Razor components
Synchronous methods     →    async/await
Direct instantiation    →    Dependency injection
In-memory collections   →    Entity Framework Core + SQL
Web.config              →    appsettings.json
```

### Key Transformation Areas

1. **UI Framework Migration**
   - Convert Web Forms pages to Blazor components
   - Replace Repeater with @foreach loops
   - Replace server controls with Razor syntax

2. **State Management**
   - Replace Session with distributed cache
   - Implement proper cart service with DI
   - Use component parameters for state

3. **Data Access**
   - Replace repositories with EF Core DbContext
   - Add repository interfaces
   - Implement async data access

4. **Architecture**
   - Introduce service layer
   - Implement CQRS with MediatR
   - Add logging with ILogger

5. **Modern Practices**
   - Add unit tests
   - Implement CI/CD pipelines
   - Containerize with Docker

## Code Documentation

Every file includes detailed comments marking legacy patterns:

```csharp
// LEGACY PATTERN: Description of the legacy approach
// MODERNIZATION PATH: Suggested modern alternative
// MODERNIZATION NOTE: Additional context
```

Search for these markers to understand transformation opportunities.

## Known Limitations

These are intentional legacy patterns, not bugs:

- ✗ No async/await (synchronous blocking calls)
- ✗ No dependency injection (direct instantiation)
- ✗ No unit tests (coupled code-behind)
- ✗ No logging framework (Debug.WriteLine only)
- ✗ No API layer (server-rendered only)
- ✗ No authentication (no user management)
- ✗ No real database (in-memory simulation)
- ✗ No error boundaries (basic try/catch)
- ✗ Session state won't scale to multiple servers
- ✗ ViewState increases page payload

## License

This is a demonstration application for modernization scenarios.

## Additional Resources

- [ASP.NET Web Forms Documentation](https://docs.microsoft.com/en-us/aspnet/web-forms/)
- [.NET Framework 4.7.2](https://dotnet.microsoft.com/download/dotnet-framework/net472)
- [Blazor Migration Guide](https://docs.microsoft.com/en-us/aspnet/core/blazor/)
- [Modernization Patterns](https://docs.microsoft.com/en-us/dotnet/architecture/modernize-with-azure-containers/)
