using System;
using System.Collections.Generic;
using System.Linq;
using PizzaShop.WebForms.Models;

namespace PizzaShop.WebForms.Data
{
    /// <summary>
    /// Repository for topping data access
    /// LEGACY PATTERN: Static in-memory data store, no abstraction
    /// MODERNIZATION PATH: Interface-based repository with EF Core
    /// </summary>
    public class ToppingRepository
    {
        // LEGACY PATTERN: Static collection as data store
        // MODERNIZATION NOTE: Replace with DbContext and database table
        // MODERNIZATION PATH: Entity Framework Core DbSet<Topping>
        
        private static List<Topping> _toppings;
        private static int _nextId = 1;

        // LEGACY PATTERN: Static constructor for initialization
        // MODERNIZATION PATH: Database migrations and seed data
        static ToppingRepository()
        {
            InitializeToppings();
        }

        /// <summary>
        /// Initialize hardcoded topping data
        /// LEGACY PATTERN: In-memory simulation of database records
        /// MODERNIZATION NOTE: Would be actual database rows
        /// </summary>
        private static void InitializeToppings()
        {
            _toppings = new List<Topping>
            {
                // Cheeses
                new Topping
                {
                    Id = _nextId++,
                    Name = "Extra Mozzarella",
                    Price = 1.50m,
                    Category = "Cheese",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/mozzarella.png",
                    DisplayOrder = 1
                },
                
                // Meats
                new Topping
                {
                    Id = _nextId++,
                    Name = "Pepperoni",
                    Price = 1.50m,
                    Category = "Meat",
                    IsVegetarian = false,
                    ImageUrl = "~/Images/toppings/pepperoni.png",
                    DisplayOrder = 10
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Italian Sausage",
                    Price = 1.75m,
                    Category = "Meat",
                    IsVegetarian = false,
                    ImageUrl = "~/Images/toppings/sausage.png",
                    DisplayOrder = 11
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Grilled Chicken",
                    Price = 2.00m,
                    Category = "Meat",
                    IsVegetarian = false,
                    ImageUrl = "~/Images/toppings/chicken.png",
                    DisplayOrder = 12
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Ground Beef",
                    Price = 1.75m,
                    Category = "Meat",
                    IsVegetarian = false,
                    ImageUrl = "~/Images/toppings/beef.png",
                    DisplayOrder = 13
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Bacon",
                    Price = 2.00m,
                    Category = "Meat",
                    IsVegetarian = false,
                    ImageUrl = "~/Images/toppings/bacon.png",
                    DisplayOrder = 14
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Canadian Bacon",
                    Price = 1.75m,
                    Category = "Meat",
                    IsVegetarian = false,
                    ImageUrl = "~/Images/toppings/ham.png",
                    DisplayOrder = 15
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Anchovies",
                    Price = 1.50m,
                    Category = "Meat",
                    IsVegetarian = false,
                    ImageUrl = "~/Images/toppings/anchovies.png",
                    DisplayOrder = 16
                },
                
                // Vegetables
                new Topping
                {
                    Id = _nextId++,
                    Name = "Mushrooms",
                    Price = 1.00m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/mushrooms.png",
                    DisplayOrder = 20
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Red Onions",
                    Price = 0.75m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/onions.png",
                    DisplayOrder = 21
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Green Peppers",
                    Price = 1.00m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/peppers.png",
                    DisplayOrder = 22
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Black Olives",
                    Price = 1.00m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/olives.png",
                    DisplayOrder = 23
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Pineapple",
                    Price = 1.25m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/pineapple.png",
                    DisplayOrder = 24
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Tomatoes",
                    Price = 1.00m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/tomatoes.png",
                    DisplayOrder = 25
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Jalapeños",
                    Price = 0.75m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/jalapenos.png",
                    DisplayOrder = 26
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Spinach",
                    Price = 1.25m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/spinach.png",
                    DisplayOrder = 27
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Garlic",
                    Price = 0.75m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/garlic.png",
                    DisplayOrder = 28
                },
                new Topping
                {
                    Id = _nextId++,
                    Name = "Basil",
                    Price = 0.75m,
                    Category = "Vegetable",
                    IsVegetarian = true,
                    ImageUrl = "~/Images/toppings/basil.png",
                    DisplayOrder = 29
                }
            };
        }

        /// <summary>
        /// Get all toppings
        /// LEGACY PATTERN: Synchronous method returning List
        /// MODERNIZATION PATH: async Task<List<Topping>> GetAllAsync()
        /// </summary>
        public List<Topping> GetAll()
        {
            // LEGACY PATTERN: Return copy to prevent external modification
            // MODERNIZATION PATH: Return IReadOnlyList or use immutable collections
            
            return _toppings.OrderBy(t => t.DisplayOrder).ToList();
        }

        /// <summary>
        /// Get topping by ID
        /// LEGACY PATTERN: Synchronous lookup with null return
        /// MODERNIZATION PATH: async Task<Topping?> with nullable reference
        /// </summary>
        public Topping GetById(int id)
        {
            // LEGACY PATTERN: FirstOrDefault can return null
            // MODERNIZATION NOTE: Enable nullable reference types
            
            return _toppings.FirstOrDefault(t => t.Id == id);
        }

        /// <summary>
        /// Get toppings by category
        /// LEGACY PATTERN: String-based category filter
        /// MODERNIZATION PATH: Enum-based categories with type safety
        /// </summary>
        public List<Topping> GetByCategory(string category)
        {
            // LEGACY PATTERN: Case-insensitive string comparison
            // MODERNIZATION PATH: Strongly-typed enum for categories
            
            if (string.IsNullOrEmpty(category))
                return GetAll();

            return _toppings
                .Where(t => t.Category.Equals(category, StringComparison.OrdinalIgnoreCase))
                .OrderBy(t => t.DisplayOrder)
                .ToList();
        }

        /// <summary>
        /// Get vegetarian toppings only
        /// LEGACY PATTERN: Filter by boolean property
        /// MODERNIZATION NOTE: Could use specification pattern
        /// </summary>
        public List<Topping> GetVegetarianToppings()
        {
            // LEGACY PATTERN: Direct LINQ query
            // MODERNIZATION PATH: Specification pattern or query objects
            
            return _toppings
                .Where(t => t.IsVegetarian)
                .OrderBy(t => t.DisplayOrder)
                .ToList();
        }

        /// <summary>
        /// Get all topping categories
        /// LEGACY PATTERN: Distinct string values from data
        /// MODERNIZATION PATH: Enum or separate lookup table
        /// </summary>
        public List<string> GetCategories()
        {
            // LEGACY PATTERN: Extract distinct values
            // MODERNIZATION PATH: Define categories as enum
            
            return _toppings
                .Select(t => t.Category)
                .Distinct()
                .OrderBy(c => c)
                .ToList();
        }

        /// <summary>
        /// Get toppings by IDs
        /// LEGACY PATTERN: Filter by ID list
        /// MODERNIZATION PATH: Async query with Contains()
        /// </summary>
        public List<Topping> GetByIds(List<int> ids)
        {
            // LEGACY PATTERN: LINQ Contains for filtering
            // MODERNIZATION NOTE: Consider performance with large ID lists
            
            if (ids == null || ids.Count == 0)
                return new List<Topping>();

            return _toppings
                .Where(t => ids.Contains(t.Id))
                .OrderBy(t => t.DisplayOrder)
                .ToList();
        }

        // LEGACY PATTERN: No interface, direct instantiation required
        // MODERNIZATION NOTE: Should implement IToppingRepository
        // MODERNIZATION PATH:
        // public interface IToppingRepository
        // {
        //     Task<List<Topping>> GetAllAsync();
        //     Task<Topping?> GetByIdAsync(int id);
        //     Task<List<Topping>> GetByCategoryAsync(string category);
        //     Task<List<Topping>> GetVegetarianToppingsAsync();
        // }
    }
}
