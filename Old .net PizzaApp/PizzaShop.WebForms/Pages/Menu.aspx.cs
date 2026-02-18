using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using PizzaShop.WebForms.Data;
using PizzaShop.WebForms.Models;

namespace PizzaShop.WebForms.Pages
{
    /// <summary>
    /// Menu page code-behind
    /// LEGACY PATTERN: Code-behind with server-side event handlers
    /// MODERNIZATION PATH: Razor Pages with handlers or Blazor with event callbacks
    /// </summary>
    public partial class Menu : System.Web.UI.Page
    {
        // LEGACY PATTERN: Direct instantiation, no dependency injection
        // MODERNIZATION PATH: Constructor injection with interfaces
        private PizzaRepository _pizzaRepository = new PizzaRepository();

        /// <summary>
        /// Page Load event
        /// LEGACY PATTERN: Page lifecycle event handling
        /// MODERNIZATION PATH: OnGet() handler in Razor Pages
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // LEGACY PATTERN: Initialize controls on first load only
                // MODERNIZATION NOTE: IsPostBack check prevents re-initialization
                
                LoadCategories();
                LoadPizzas();
            }
        }

        /// <summary>
        /// Load categories into dropdown filter
        /// LEGACY PATTERN: Manual list item creation and databinding
        /// MODERNIZATION PATH: Model binding or component binding
        /// </summary>
        private void LoadCategories()
        {
            try
            {
                // Get all categories from repository
                var categories = _pizzaRepository.GetCategories();
                
                // LEGACY PATTERN: Clear and manually populate dropdown
                // MODERNIZATION PATH: Use data binding with ItemsSource
                CategoryFilter.Items.Clear();
                
                // Add "All" option
                CategoryFilter.Items.Add(new ListItem("All Pizzas", ""));
                
                // Add category options
                foreach (var category in categories)
                {
                    CategoryFilter.Items.Add(new ListItem(category, category));
                }
            }
            catch (Exception ex)
            {
                // LEGACY PATTERN: Basic error logging
                // MODERNIZATION PATH: ILogger with structured logging
                System.Diagnostics.Debug.WriteLine($"Error loading categories: {ex.Message}");
            }
        }

        /// <summary>
        /// Load pizzas based on selected category filter
        /// LEGACY PATTERN: Manual databinding to Repeater control
        /// MODERNIZATION PATH: Automatic model binding
        /// </summary>
        private void LoadPizzas()
        {
            try
            {
                List<Pizza> pizzas;
                string selectedCategory = CategoryFilter.SelectedValue;
                
                // LEGACY PATTERN: Conditional data loading based on selection
                // MODERNIZATION PATH: Query filters or specification pattern
                
                if (string.IsNullOrEmpty(selectedCategory))
                {
                    // Load all pizzas
                    pizzas = _pizzaRepository.GetAllPremadePizzas();
                }
                else
                {
                    // Filter by category
                    pizzas = _pizzaRepository.GetByCategory(selectedCategory);
                }
                
                // LEGACY PATTERN: Show/hide panel based on data
                // MODERNIZATION PATH: Conditional rendering with @if in Razor/Blazor
                if (pizzas.Count == 0)
                {
                    NoResultsPanel.Visible = true;
                    PizzaRepeater.Visible = false;
                }
                else
                {
                    NoResultsPanel.Visible = false;
                    PizzaRepeater.Visible = true;
                    
                    // LEGACY PATTERN: Two-step databinding (set source, then bind)
                    // MODERNIZATION PATH: One-step model binding
                    PizzaRepeater.DataSource = pizzas;
                    PizzaRepeater.DataBind();
                }
            }
            catch (Exception ex)
            {
                // LEGACY PATTERN: Exception handling with debug output
                // MODERNIZATION PATH: Proper logging and error pages
                System.Diagnostics.Debug.WriteLine($"Error loading pizzas: {ex.Message}");
                NoResultsPanel.Visible = true;
                PizzaRepeater.Visible = false;
            }
        }

        /// <summary>
        /// Handle category filter selection change
        /// LEGACY PATTERN: AutoPostBack causes full page refresh
        /// MODERNIZATION NOTE: Entire page reloads just to filter list
        /// MODERNIZATION PATH: Client-side filtering or AJAX partial update
        /// </summary>
        protected void CategoryFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Reload data on dropdown change
            // MODERNIZATION NOTE: This triggers a full page postback
            // MODERNIZATION PATH: Use JavaScript filtering or AJAX UpdatePanel
            
            LoadPizzas();
        }

        /// <summary>
        /// Handle Add to Cart button clicks from repeater items
        /// LEGACY PATTERN: ItemCommand event with CommandArgument
        /// MODERNIZATION PATH: Component events or API calls
        /// </summary>
        protected void PizzaRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // LEGACY PATTERN: String parsing from CommandArgument
            // MODERNIZATION NOTE: Not type-safe, prone to errors
            // MODERNIZATION PATH: Strongly-typed event args or DTOs
            
            if (e.CommandName == "AddToCart")
            {
                try
                {
                    // Parse command argument (format: "pizzaId|size")
                    string argument = e.CommandArgument.ToString();
                    string[] parts = argument.Split('|');
                    
                    if (parts.Length == 2)
                    {
                        int pizzaId = int.Parse(parts[0]);
                        string size = parts[1];
                        
                        AddToCart(pizzaId, size);
                    }
                }
                catch (Exception ex)
                {
                    // LEGACY PATTERN: Silent error handling
                    // MODERNIZATION PATH: User notification and logging
                    System.Diagnostics.Debug.WriteLine($"Error adding to cart: {ex.Message}");
                }
            }
        }

        /// <summary>
        /// Add pizza to shopping cart session
        /// LEGACY PATTERN: Session state for cart storage
        /// MODERNIZATION NOTE: Not scalable, doesn't work in web farms without sticky sessions
        /// MODERNIZATION PATH: Distributed cache (Redis) or database-backed cart
        /// </summary>
        private void AddToCart(int pizzaId, string size)
        {
            try
            {
                // Get pizza from repository
                var pizza = _pizzaRepository.GetById(pizzaId);
                
                if (pizza != null)
                {
                    // LEGACY PATTERN: Direct session access
                    // MODERNIZATION PATH: Injected cart service
                    var cart = Session["Cart"] as List<OrderItem>;
                    
                    if (cart == null)
                    {
                        cart = new List<OrderItem>();
                        Session["Cart"] = cart;
                    }
                    
                    // Calculate price based on size
                    decimal unitPrice = pizza.GetPrice(size);
                    
                    // Check if item already exists in cart
                    var existingItem = cart.FirstOrDefault(item => 
                        item.Pizza?.Id == pizza.Id && 
                        item.Size == size &&
                        item.PizzaName == pizza.Name);
                    
                    if (existingItem != null)
                    {
                        // LEGACY PATTERN: Direct property modification
                        // MODERNIZATION PATH: Domain methods with validation
                        existingItem.Quantity++;
                    }
                    else
                    {
                        // Create new order item
                        var orderItem = new OrderItem(
                            pizza,
                            size,
                            "Regular", // Default crust for pre-made pizzas
                            new List<string>(), // Pre-made pizzas have fixed toppings
                            unitPrice
                        );
                        
                        // Assign unique ID
                        // LEGACY PATTERN: Simple incrementing ID
                        orderItem.Id = cart.Count > 0 ? cart.Max(i => i.Id) + 1 : 1;
                        
                        cart.Add(orderItem);
                    }
                    
                    // Update session
                    Session["Cart"] = cart;
                    
                    // LEGACY PATTERN: Page redirect with query string
                    // MODERNIZATION NOTE: Loses scroll position, full page reload
                    // MODERNIZATION PATH: Toast notification without page reload
                    Response.Redirect("Menu.aspx?added=1");
                }
            }
            catch (Exception ex)
            {
                // LEGACY PATTERN: Basic exception logging
                // MODERNIZATION PATH: Structured logging with context
                System.Diagnostics.Debug.WriteLine($"Error in AddToCart: {ex.Message}");
            }
        }

        // LEGACY PATTERN: Multiple event handlers and manual state management
        // MODERNIZATION NOTE: Code-behind becomes complex with business logic
        // MODERNIZATION PATH:
        // - Razor Pages: OnGet/OnPost handlers with dependency injection
        // - Blazor: Event callbacks and injected services
        // - API + SPA: RESTful endpoints with client-side state management
    }
}
