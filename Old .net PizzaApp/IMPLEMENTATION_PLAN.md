# Legacy .NET Pizza Shop - Implementation Plan

**Project**: PizzaShop.WebForms  
**Technology Stack**: ASP.NET Web Forms on .NET Framework 4.7.2  
**Purpose**: AI-driven modernization demonstration showcasing transformation from legacy to modern .NET

---

## 🎯 Project Objectives

Create a classic ASP.NET Web Forms pizza ordering application with **intentionally legacy patterns** documented for future AI-assisted modernization. The app features:
- Pre-made pizza menu
- Custom pizza builder
- Shopping cart functionality
- Modern Bootstrap 3.x UI with legacy delivery mechanism

---

## 🏗️ Architecture Overview

### Legacy Technology Stack
- **Framework**: .NET Framework 4.7.2
- **Web Platform**: ASP.NET Web Forms
- **UI Framework**: Bootstrap 3.3.7
- **JavaScript**: jQuery 2.2.4
- **Data Storage**: In-memory collections (simulated)
- **State Management**: Session state (InProc)
- **AJAX**: UpdatePanel / AJAX Control Toolkit

### Intentional Legacy Patterns
1. **ViewState** - Heavy state management on client
2. **Code-Behind** - Tight coupling between UI and logic
3. **Session State** - Server-side session dependency
4. **Postback Model** - Full page lifecycle for interactions
5. **Server Controls** - GridView, Repeater, DropDownList, etc.
6. **No Dependency Injection** - Direct instantiation
7. **No Async/Await** - Synchronous operations only
8. **Global.asax** - Application-level event handling

---

## 📁 Project Structure

```
Old .net PizzaApp/
└── PizzaShop.WebForms/
    ├── Pages/                  # Web Forms pages (.aspx/.aspx.cs)
    │   ├── Menu.aspx
    │   ├── BuildPizza.aspx
    │   ├── Cart.aspx
    │   └── Default.aspx
    ├── Models/                 # Business entities
    │   ├── Pizza.cs
    │   ├── Topping.cs
    │   ├── OrderItem.cs
    │   └── Order.cs
    ├── Data/                   # Data access layer
    │   ├── PizzaRepository.cs
    │   └── ToppingRepository.cs
    ├── Content/                # Static CSS files
    │   └── site.css
    ├── Scripts/                # JavaScript files
    │   └── (Bootstrap/jQuery)
    ├── Images/                 # Pizza images
    ├── App_Code/              # Helper classes
    ├── Site.Master            # Master page layout
    ├── Web.config             # Configuration
    └── Global.asax            # Application events
```

---

## 📋 Implementation Steps

### Step 1: Project Structure Setup ✓
- Create ASP.NET Web Forms project targeting .NET Framework 4.7.2
- Establish folder structure with documentation
- Add Web.config with legacy session state configuration
- Include Global.asax for application-level event handling

### Step 2: Master Page & Layout
- Bootstrap 3.3.7 CSS framework integration
- jQuery 2.2.4 for client-side interactions
- Shared navigation: Home, Menu, Build Pizza, Cart
- Legacy pattern: Server-side controls with inline CSS classes
- Document ViewState usage and postback model in MODERNIZATION NOTES

### Step 3: Data Models & In-Memory Repository
- Create Pizza, Topping, OrderItem, Order models
- Implement PizzaRepository with static collections
- Use direct property access pattern (no async, no LINQ complexity)
- Document lack of dependency injection and ORM

### Step 4: Menu Page (Menu.aspx)
- Use Repeater/GridView Web Forms controls
- Server-side click events for "Add to Cart"
- ViewState-based data binding
- Session state for cart management

### Step 5: Custom Pizza Builder (BuildPizza.aspx)
- Size selection: RadioButtonList
- Crust type: DropDownList
- Toppings: CheckBoxList
- Real-time price calculation using UpdatePanel
- RequiredFieldValidator and CustomValidator

### Step 6: Shopping Cart (Cart.aspx)
- Display cart items from Session using GridView
- Quantity adjustment with postbacks
- Remove item functionality
- Order total calculation
- Checkout simulation

### Step 7: Styling & UI Polish
- Bootstrap 3.x card components
- Custom CSS for pizza builder
- Responsive grid layout
- Modern color scheme with legacy delivery

### Step 8: Documentation & Modernization Notes
- README.md with tech stack and modernization opportunities
- Inline code comments with "LEGACY PATTERN:" markers
- Side-by-side comparison table

### Step 9: Deployment Script
- PowerShell script for IIS deployment
- Application pool configuration
- Error handling and logging

---

## 🔄 Modernization Path

### Current State → Future State

| Component | Legacy (.NET Framework 4.7.2) | Modern (.NET 8+) |
|-----------|-------------------------------|------------------|
| Framework | ASP.NET Web Forms | Blazor Server/WASM |
| State | ViewState + Session | Component state + SignalR |
| Data Binding | Server controls | Two-way binding |
| AJAX | UpdatePanel | WebSocket/fetch API |
| DI | None (direct instantiation) | Built-in DI container |
| Data Access | Static collections | Entity Framework Core |
| Async | Synchronous only | async/await pattern |
| Deployment | IIS + Windows Server | Azure App Service (Linux) |
| Configuration | Web.config (XML) | appsettings.json |

---

## 🎨 Features Implemented

### Core Features
- ✅ Browse pre-made pizza menu
- ✅ Custom pizza builder (size, crust, toppings)
- ✅ Shopping cart with add/remove/update
- ✅ Real-time price calculation
- ✅ Order simulation

### UI/UX Features
- Modern Bootstrap 3.x styling
- Responsive design
- Visual feedback for interactions
- Price breakdown display
- Cart persistence across navigation

---

## 🚀 Deployment Requirements

### Prerequisites
- Windows Server 2012 R2+ or Windows 10/11
- IIS 8.0+
- .NET Framework 4.7.2 Runtime
- Visual Studio 2017+ (for development)

### IIS Configuration
- Application Pool: .NET CLR v4.0.30319
- Managed Pipeline Mode: Integrated
- Session State: InProc (default)

---

## 📝 Key Documentation Markers

Throughout the codebase, look for these comment patterns:

```csharp
// LEGACY PATTERN: [Description of what makes this legacy]

// MODERNIZATION NOTE: [How this should be transformed]

// MODERNIZATION PATH: [Specific modern equivalent]
```

---

## ✅ Verification Checklist

- [ ] Application runs in Visual Studio with IIS Express
- [ ] Pre-made pizza ordering flow works end-to-end
- [ ] Custom pizza builder calculates price correctly
- [ ] Cart operations (add, update, remove) function properly
- [ ] Session state persists across page navigation
- [ ] All MODERNIZATION NOTES are documented
- [ ] README.md explains modernization opportunities
- [ ] Deployment script successfully deploys to IIS

---

## 🎯 Success Criteria

The application successfully demonstrates:
1. **Realistic legacy patterns** that exist in enterprise applications
2. **Clear modernization opportunities** documented in code
3. **Visual appeal** despite legacy technology stack
4. **Working functionality** that can be compared post-modernization
5. **AI-assisted transformation potential** for demo purposes

---

**Document Version**: 1.0  
**Last Updated**: February 18, 2026  
**Status**: Implementation In Progress
