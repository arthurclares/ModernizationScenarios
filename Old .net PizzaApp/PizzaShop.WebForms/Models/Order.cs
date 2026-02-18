using System;
using System.Collections.Generic;
using System.Linq;

namespace PizzaShop.WebForms.Models
{
    /// <summary>
    /// Represents a customer order
    /// LEGACY PATTERN: Simple aggregate class with list of items
    /// MODERNIZATION PATH: Rich domain aggregate with domain events
    /// </summary>
    public class Order
    {
        // LEGACY PATTERN: Public setters on all properties
        // MODERNIZATION PATH: Encapsulated state with controlled mutation
        
        /// <summary>
        /// Unique order identifier
        /// </summary>
        public int OrderId { get; set; }

        /// <summary>
        /// Order date and time
        /// </summary>
        public DateTime OrderDate { get; set; }

        /// <summary>
        /// List of items in the order
        /// LEGACY PATTERN: Direct list exposure
        /// MODERNIZATION PATH: ReadOnlyCollection or IReadOnlyList
        /// </summary>
        public List<OrderItem> Items { get; set; }

        /// <summary>
        /// Order status (e.g., "Pending", "Preparing", "Ready", "Delivered")
        /// LEGACY PATTERN: String-based status
        /// MODERNIZATION PATH: Enum for type safety and state machine
        /// </summary>
        public string Status { get; set; }

        /// <summary>
        /// Customer name
        /// </summary>
        public string CustomerName { get; set; }

        /// <summary>
        /// Customer phone number
        /// </summary>
        public string CustomerPhone { get; set; }

        /// <summary>
        /// Delivery address (if applicable)
        /// </summary>
        public string DeliveryAddress { get; set; }

        /// <summary>
        /// Order type: "Pickup" or "Delivery"
        /// LEGACY PATTERN: String-based type
        /// MODERNIZATION PATH: Enum for order type
        /// </summary>
        public string OrderType { get; set; }

        /// <summary>
        /// Special instructions or notes
        /// </summary>
        public string Notes { get; set; }

        /// <summary>
        /// Subtotal (sum of all items before tax)
        /// LEGACY PATTERN: Calculated property computed on access
        /// </summary>
        public decimal Subtotal
        {
            get
            {
                // LEGACY PATTERN: LINQ query in property getter
                // MODERNIZATION NOTE: Consider caching or computed columns in DB
                
                if (Items == null || Items.Count == 0)
                    return 0;

                return Items.Sum(item => item.TotalPrice);
            }
        }

        /// <summary>
        /// Tax amount (assuming 8% tax rate)
        /// LEGACY PATTERN: Hardcoded tax rate
        /// MODERNIZATION PATH: Configuration-based tax calculation service
        /// </summary>
        public decimal Tax
        {
            get
            {
                // LEGACY PATTERN: Magic number for tax rate
                // MODERNIZATION NOTE: Use configuration or tax calculation service
                return Subtotal * 0.08m;
            }
        }

        /// <summary>
        /// Delivery fee (if applicable)
        /// </summary>
        public decimal DeliveryFee
        {
            get
            {
                // LEGACY PATTERN: Simple conditional logic
                // MODERNIZATION PATH: Strategy pattern or rules engine
                
                if (OrderType == "Delivery")
                    return 5.00m;
                    
                return 0;
            }
        }

        /// <summary>
        /// Total amount (subtotal + tax + delivery fee)
        /// </summary>
        public decimal Total
        {
            get
            {
                return Subtotal + Tax + DeliveryFee;
            }
        }

        // LEGACY PATTERN: Parameterless constructor
        public Order()
        {
            Items = new List<OrderItem>();
            OrderDate = DateTime.Now;
            Status = "Pending";
            OrderType = "Pickup";
        }

        /// <summary>
        /// Add an item to the order
        /// LEGACY PATTERN: Public method that modifies internal state
        /// MODERNIZATION PATH: Domain method with validation and events
        /// </summary>
        public void AddItem(OrderItem item)
        {
            // LEGACY PATTERN: No validation or business rules
            // MODERNIZATION NOTE: Add validation, duplicate detection, etc.
            
            if (item == null)
                return;

            Items.Add(item);
        }

        /// <summary>
        /// Remove an item from the order
        /// </summary>
        public void RemoveItem(int itemId)
        {
            // LEGACY PATTERN: Direct list manipulation
            // MODERNIZATION PATH: Domain event for item removed
            
            var item = Items.FirstOrDefault(i => i.Id == itemId);
            if (item != null)
            {
                Items.Remove(item);
            }
        }

        /// <summary>
        /// Update item quantity
        /// </summary>
        public void UpdateItemQuantity(int itemId, int newQuantity)
        {
            // LEGACY PATTERN: Find and update pattern
            // MODERNIZATION NOTE: Validate quantity > 0
            
            var item = Items.FirstOrDefault(i => i.Id == itemId);
            if (item != null && newQuantity > 0)
            {
                item.Quantity = newQuantity;
            }
        }

        /// <summary>
        /// Get order summary for display
        /// </summary>
        public string GetSummary()
        {
            // LEGACY PATTERN: String building for display
            // MODERNIZATION PATH: View models or Razor templates
            
            return $"Order #{OrderId} - {Items.Count} item(s) - Total: ${Total:F2}";
        }
    }
}
