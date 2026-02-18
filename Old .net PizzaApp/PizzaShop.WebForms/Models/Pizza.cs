using System;

namespace PizzaShop.WebForms.Models
{
    /// <summary>
    /// Represents a pizza product (pre-made or custom)
    /// LEGACY PATTERN: Anemic domain model with no behavior
    /// MODERNIZATION PATH: Rich domain model with business logic and validation
    /// </summary>
    public class Pizza
    {
        // LEGACY PATTERN: Auto-properties with public setters
        // MODERNIZATION PATH: Use records or private setters for immutability
        
        /// <summary>
        /// Unique identifier for the pizza
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Pizza name (e.g., "Margherita", "Pepperoni")
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Detailed description of the pizza
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// Base price for small size
        /// LEGACY PATTERN: Decimal for currency without specific currency type
        /// </summary>
        public decimal BasePrice { get; set; }

        /// <summary>
        /// URL or path to pizza image
        /// </summary>
        public string ImageUrl { get; set; }

        /// <summary>
        /// Category (e.g., "Classic", "Specialty", "Vegetarian")
        /// </summary>
        public string Category { get; set; }

        /// <summary>
        /// Indicates if this is a pre-made pizza or custom
        /// </summary>
        public bool IsPreMade { get; set; }

        /// <summary>
        /// List of topping IDs included in pre-made pizza
        /// </summary>
        public string ToppingIds { get; set; }

        // LEGACY PATTERN: No data validation attributes
        // MODERNIZATION NOTE: Add [Required], [StringLength], [Range] attributes
        // for automatic validation in ASP.NET Core

        // LEGACY PATTERN: Parameterless constructor required for data binding
        // MODERNIZATION PATH: Record types with primary constructors
        public Pizza()
        {
        }

        /// <summary>
        /// Calculate price based on size multiplier
        /// LEGACY PATTERN: Business logic in model (acceptable for simple cases)
        /// MODERNIZATION NOTE: Could move to service layer for complex calculations
        /// </summary>
        /// <param name="size">Pizza size: Small, Medium, or Large</param>
        /// <returns>Calculated price</returns>
        public decimal GetPrice(string size)
        {
            // LEGACY PATTERN: String-based size comparison
            // MODERNIZATION PATH: Use enum for type safety
            
            decimal multiplier = 1.0m;
            
            switch (size?.ToLower())
            {
                case "small":
                    multiplier = 1.0m;
                    break;
                case "medium":
                    multiplier = 1.3m;
                    break;
                case "large":
                    multiplier = 1.6m;
                    break;
                default:
                    multiplier = 1.0m;
                    break;
            }

            return BasePrice * multiplier;
        }
    }
}
