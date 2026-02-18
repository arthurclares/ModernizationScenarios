using System;
using System.Collections.Generic;

namespace PizzaShop.WebForms.Models
{
    /// <summary>
    /// Represents a single item in a shopping cart or order
    /// LEGACY PATTERN: Mutable data class with public setters
    /// MODERNIZATION PATH: Immutable record with calculated properties
    /// </summary>
    public class OrderItem
    {
        // LEGACY PATTERN: Auto-properties with public setters
        // MODERNIZATION NOTE: In modern .NET, use record types or init-only setters
        
        /// <summary>
        /// Unique identifier for the order item
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Reference to the base pizza
        /// LEGACY PATTERN: Direct object reference (not EF navigation property)
        /// </summary>
        public Pizza Pizza { get; set; }

        /// <summary>
        /// Pizza name (for display purposes)
        /// </summary>
        public string PizzaName { get; set; }

        /// <summary>
        /// Selected size: Small, Medium, or Large
        /// LEGACY PATTERN: String-based size
        /// MODERNIZATION PATH: Use enum for type safety
        /// </summary>
        public string Size { get; set; }

        /// <summary>
        /// Selected crust type (e.g., "Thin", "Regular", "Thick")
        /// </summary>
        public string CrustType { get; set; }

        /// <summary>
        /// List of selected topping names
        /// LEGACY PATTERN: Comma-separated string or simple list
        /// </summary>
        public List<string> SelectedToppings { get; set; }

        /// <summary>
        /// Quantity of this item
        /// </summary>
        public int Quantity { get; set; }

        /// <summary>
        /// Unit price for one item
        /// </summary>
        public decimal UnitPrice { get; set; }

        /// <summary>
        /// Total price for this line item (UnitPrice * Quantity)
        /// LEGACY PATTERN: Calculated property stored in field
        /// MODERNIZATION PATH: Computed property or domain event
        /// </summary>
        public decimal TotalPrice
        {
            get
            {
                return UnitPrice * Quantity;
            }
        }

        // LEGACY PATTERN: Parameterless constructor for serialization
        public OrderItem()
        {
            SelectedToppings = new List<string>();
            Quantity = 1;
        }

        /// <summary>
        /// Constructor with parameters
        /// LEGACY PATTERN: Manual object initialization
        /// MODERNIZATION PATH: Record types with primary constructor
        /// </summary>
        public OrderItem(Pizza pizza, string size, string crustType, List<string> toppings, decimal unitPrice)
        {
            Pizza = pizza;
            PizzaName = pizza?.Name ?? "Custom Pizza";
            Size = size;
            CrustType = crustType;
            SelectedToppings = toppings ?? new List<string>();
            Quantity = 1;
            UnitPrice = unitPrice;
        }

        /// <summary>
        /// Get formatted description of the order item
        /// </summary>
        public string GetDescription()
        {
            // LEGACY PATTERN: String building for display
            // MODERNIZATION PATH: Use view models or display templates
            
            string description = $"{Size} {PizzaName} on {CrustType} Crust";
            
            if (SelectedToppings != null && SelectedToppings.Count > 0)
            {
                description += $" with {string.Join(", ", SelectedToppings)}";
            }
            
            return description;
        }
    }
}
