using System;
using System.Collections.Generic;
using System.Linq;
using PizzaShop.WebForms.Models;

namespace PizzaShop.WebForms.Data
{
    /// <summary>
    /// Repository for pizza data access
    /// LEGACY PATTERN: Static in-memory data store with no interface
    /// MODERNIZATION PATH: Interface-based repository with EF Core and DI
    /// </summary>
    public class PizzaRepository
    {
        // LEGACY PATTERN: Static list as "database"
        // MODERNIZATION NOTE: Replace with DbContext and DbSet<Pizza>
        // MODERNIZATION PATH: Use Entity Framework Core with SQL Server or Cosmos DB
        
        private static List<Pizza> _pizzas;
        private static int _nextId = 1;

        // LEGACY PATTERN: Static constructor for data initialization
        // MODERNIZATION PATH: Database seeding or migration scripts
        static PizzaRepository()
        {
            InitializePizzas();
        }

        /// <summary>
        /// Initialize hardcoded pizza data
        /// LEGACY PATTERN: In-memory data simulation
        /// MODERNIZATION NOTE: Would be replaced by database records
        /// </summary>
        private static void InitializePizzas()
        {
            _pizzas = new List<Pizza>
            {
                new Pizza
                {
                    Id = _nextId++,
                    Name = "Margherita",
                    Description = "Classic pizza with fresh mozzarella, tomato sauce, and basil",
                    BasePrice = 10.99m,
                    Category = "Classic",
                    IsPreMade = true,
                    ImageUrl = "~/Images/pizza-margherita.jpg",
                    ToppingIds = "1,5,8" // Mozzarella, Tomato Sauce, Basil
                },
                new Pizza
                {
                    Id = _nextId++,
                    Name = "Pepperoni",
                    Description = "America's favorite with pepperoni and mozzarella cheese",
                    BasePrice = 12.99m,
                    Category = "Classic",
                    IsPreMade = true,
                    ImageUrl = "~/Images/pizza-pepperoni.jpg",
                    ToppingIds = "1,2,5" // Mozzarella, Pepperoni, Tomato Sauce
                },
                new Pizza
                {
                    Id = _nextId++,
                    Name = "Meat Lovers",
                    Description = "Loaded with pepperoni, sausage, bacon, and ham",
                    BasePrice = 15.99m,
                    Category = "Specialty",
                    IsPreMade = true,
                    ImageUrl = "~/Images/pizza-meat-lovers.jpg",
                    ToppingIds = "1,2,3,6,7" // Mozzarella, Pepperoni, Sausage, Bacon, Ham
                },
                new Pizza
                {
                    Id = _nextId++,
                    Name = "Vegetarian Supreme",
                    Description = "Garden fresh mushrooms, onions, peppers, and olives",
                    BasePrice = 13.99m,
                    Category = "Vegetarian",
                    IsPreMade = true,
                    ImageUrl = "~/Images/pizza-veggie.jpg",
                    ToppingIds = "1,5,9,10,11,12" // Mozzarella, Tomato Sauce, Mushrooms, Onions, Peppers, Olives
                },
                new Pizza
                {
                    Id = _nextId++,
                    Name = "Hawaiian",
                    Description = "Tropical delight with pineapple and Canadian bacon",
                    BasePrice = 13.49m,
                    Category = "Specialty",
                    IsPreMade = true,
                    ImageUrl = "~/Images/pizza-hawaiian.jpg",
                    ToppingIds = "1,5,7,13" // Mozzarella, Tomato Sauce, Ham, Pineapple
                },
                new Pizza
                {
                    Id = _nextId++,
                    Name = "BBQ Chicken",
                    Description = "Tangy BBQ sauce, grilled chicken, onions, and cilantro",
                    BasePrice = 14.99m,
                    Category = "Specialty",
                    IsPreMade = true,
                    ImageUrl = "~/Images/pizza-bbq-chicken.jpg",
                    ToppingIds = "1,4,10,14" // Mozzarella, Chicken, Onions, BBQ Sauce
                },
                new Pizza
                {
                    Id = _nextId++,
                    Name = "Supreme",
                    Description = "The works! Sausage, pepperoni, mushrooms, onions, peppers",
                    BasePrice = 16.99m,
                    Category = "Specialty",
                    IsPreMade = true,
                    ImageUrl = "~/Images/pizza-supreme.jpg",
                    ToppingIds = "1,2,3,5,9,10,11" // All the toppings
                },
                new Pizza
                {
                    Id = _nextId++,
                    Name = "Four Cheese",
                    Description = "Blend of mozzarella, parmesan, provolone, and gorgonzola",
                    BasePrice = 13.99m,
                    Category = "Classic",
                    IsPreMade = true,
                    ImageUrl = "~/Images/pizza-four-cheese.jpg",
                    ToppingIds = "1,5,15,16" // Multiple cheeses
                }
            };
        }

        /// <summary>
        /// Get all pre-made pizzas
        /// LEGACY PATTERN: Synchronous method returning List
        /// MODERNIZATION PATH: async Task<List<Pizza>> with EF Core
        /// </summary>
        public List<Pizza> GetAllPremadePizzas()
        {
            // LEGACY PATTERN: LINQ to Objects on in-memory list
            // MODERNIZATION PATH: LINQ to Entities with async ToListAsync()
            
            return _pizzas.Where(p => p.IsPreMade).ToList();
        }

        /// <summary>
        /// Get pizza by ID
        /// LEGACY PATTERN: Synchronous method with null return
        /// MODERNIZATION PATH: async Task<Pizza?> or Result pattern
        /// </summary>
        public Pizza GetById(int id)
        {
            // LEGACY PATTERN: FirstOrDefault with null reference possibility
            // MODERNIZATION NOTE: Consider nullable reference types
            
            return _pizzas.FirstOrDefault(p => p.Id == id);
        }

        /// <summary>
        /// Get pizzas by category
        /// LEGACY PATTERN: String-based category filtering
        /// MODERNIZATION PATH: Enum-based category with query specification pattern
        /// </summary>
        public List<Pizza> GetByCategory(string category)
        {
            // LEGACY PATTERN: Case-insensitive string comparison
            // MODERNIZATION PATH: Strongly-typed category enum
            
            if (string.IsNullOrEmpty(category))
                return GetAllPremadePizzas();

            return _pizzas.Where(p => 
                p.IsPreMade && 
                p.Category.Equals(category, StringComparison.OrdinalIgnoreCase)
            ).ToList();
        }

        /// <summary>
        /// Get all categories
        /// LEGACY PATTERN: Distinct string values
        /// MODERNIZATION PATH: Enum values or separate Category table
        /// </summary>
        public List<string> GetCategories()
        {
            // LEGACY PATTERN: LINQ Distinct on string property
            // MODERNIZATION PATH: Separate lookup table or enum
            
            return _pizzas
                .Where(p => p.IsPreMade)
                .Select(p => p.Category)
                .Distinct()
                .OrderBy(c => c)
                .ToList();
        }

        /// <summary>
        /// Add a new pizza
        /// LEGACY PATTERN: Direct list manipulation
        /// MODERNIZATION PATH: DbContext.Add() with SaveChanges()
        /// </summary>
        public Pizza Add(Pizza pizza)
        {
            // LEGACY PATTERN: Manual ID assignment
            // MODERNIZATION PATH: Database-generated identity column
            
            if (pizza == null)
                return null;

            pizza.Id = _nextId++;
            _pizzas.Add(pizza);
            
            return pizza;
        }

        // LEGACY PATTERN: No interface, no dependency injection
        // MODERNIZATION NOTE: Create IPizzaRepository interface and register in DI container
        // MODERNIZATION PATH:
        // public interface IPizzaRepository
        // {
        //     Task<List<Pizza>> GetAllPremadePizzasAsync();
        //     Task<Pizza?> GetByIdAsync(int id);
        //     Task<Pizza> AddAsync(Pizza pizza);
        //     Task SaveChangesAsync();
        // }
    }
}
