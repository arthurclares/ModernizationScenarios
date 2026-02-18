# Models Folder

This folder contains the business entity classes (domain models) used throughout the application.

## Purpose

Models represent the core business entities of the pizza shop:
- Product data (pizzas, toppings)
- Order data (orders, order items)
- Shopping cart structure

## Classes in This Folder

- **Pizza.cs** - Represents a pizza product (pre-made or custom)
- **Topping.cs** - Represents available pizza toppings
- **OrderItem.cs** - Represents a single item in an order/cart
- **Order.cs** - Represents a customer order with multiple items

## Legacy Patterns to Note

### Simple POCOs
Models are Plain Old CLR Objects with automatic properties, no business logic or validation attributes.

```csharp
// LEGACY PATTERN: Anemic domain models with no behavior
// MODERNIZATION PATH: Rich domain models with business logic and data annotations
```

### No Data Annotations
Models lack validation attributes, client-side validation metadata, or entity framework configurations.

```
LEGACY PATTERN: No declarative validation or ORM mappings
MODERNIZATION PATH: Data annotations for validation and EF Core configurations
```

### Public Setters
All properties have public setters, allowing unrestricted modification.

```
LEGACY PATTERN: Fully mutable objects
MODERNIZATION PATH: Immutable records or controlled mutation
```

## Model Design

Models follow traditional class structure:
- Public properties with get/set
- Parameterless constructors
- No interfaces or base classes
- No dependency injection

## Modernization Priority

**MEDIUM** - Models can be reused with enhancements (data annotations, validation, immutability).
