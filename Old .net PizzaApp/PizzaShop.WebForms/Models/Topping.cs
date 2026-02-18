using System;

namespace PizzaShop.WebForms.Models
{
    /// <summary>
    /// Represents a pizza topping option
    /// LEGACY PATTERN: Simple POCO with no validation or behavior
    /// MODERNIZATION PATH: Add data annotations and business rules
    /// </summary>
    public class Topping
    {
        // LEGACY PATTERN: Public properties with full mutability
        // MODERNIZATION PATH: Immutable records or init-only properties
        
        /// <summary>
        /// Unique identifier for the topping
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Topping name (e.g., "Pepperoni", "Mushrooms", "Extra Cheese")
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Additional cost for this topping
        /// </summary>
        public decimal Price { get; set; }

        /// <summary>
        /// Category of topping (e.g., "Meat", "Vegetable", "Cheese")
        /// </summary>
        public string Category { get; set; }

        /// <summary>
        /// Indicates if this is a vegetarian topping
        /// </summary>
        public bool IsVegetarian { get; set; }

        /// <summary>
        /// URL or path to topping icon/image
        /// </summary>
        public string ImageUrl { get; set; }

        /// <summary>
        /// Display order for UI presentation
        /// </summary>
        public int DisplayOrder { get; set; }

        // LEGACY PATTERN: No constructor
        // MODERNIZATION NOTE: Could use required properties in C# 11+
        public Topping()
        {
        }

        // LEGACY PATTERN: No validation logic
        // MODERNIZATION PATH: Implement IValidatableObject or use FluentValidation

        /// <summary>
        /// Returns formatted display text for topping
        /// </summary>
        /// <returns>Display text with price</returns>
        public string GetDisplayText()
        {
            // LEGACY PATTERN: String concatenation for display
            // MODERNIZATION PATH: Use string interpolation or display templates
            
            return $"{Name} (+${Price:F2})";
        }
    }
}
