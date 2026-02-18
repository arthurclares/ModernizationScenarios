# Data Folder

This folder contains the data access layer, responsible for retrieving and managing pizza shop data.

## Purpose

The data layer simulates a database using in-memory collections. In a real enterprise application, this would interface with SQL Server using ADO.NET or Entity Framework.

## Classes in This Folder

- **PizzaRepository.cs** - Manages pizza product data
- **ToppingRepository.cs** - Manages available toppings

## Legacy Patterns to Note

### Static Collections
Data is stored in static `List<T>` collections, simulating a database table.

```csharp
// LEGACY PATTERN: Static in-memory collections as data store
// MODERNIZATION PATH: Entity Framework Core with dependency-injected DbContext
```

### No Repository Interface
Repositories are concrete classes with no interfaces, preventing testability and dependency injection.

```
LEGACY PATTERN: Direct instantiation of repositories with new keyword
MODERNIZATION PATH: Interface-based repositories with DI container
```

### Synchronous Methods Only
All data access methods are synchronous, blocking the thread during operations.

```
LEGACY PATTERN: Synchronous data access methods
MODERNIZATION PATH: Async/await pattern with Task-based methods
```

### No ORM or Abstraction
Direct collection manipulation replaces what would typically be database queries.

```
LEGACY PATTERN: Manual collection queries with LINQ
MODERNIZATION PATH: EF Core with LINQ to Entities and change tracking
```

## Repository Pattern (Simplified)

- `GetAll()` - Returns all items
- `GetById(int id)` - Returns single item by ID
- `Add(item)` - Adds new item to collection
- No update or delete methods in this simple implementation

## Data Initialization

Static constructors initialize hardcoded data:
- 6-8 pre-made pizzas with names, descriptions, prices
- 12-15 toppings with names, prices, and categories

## Modernization Priority

**HIGH** - Data access pattern should be first to modernize, replacing with EF Core and async methods.
