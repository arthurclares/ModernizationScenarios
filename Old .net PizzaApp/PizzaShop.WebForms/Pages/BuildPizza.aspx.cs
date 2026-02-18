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
    /// Build Your Own Pizza page code-behind
    /// LEGACY PATTERN: Complex code-behind with multiple event handlers
    /// MODERNIZATION PATH: Blazor component with reactive state and computed properties
    /// </summary>
    public partial class BuildPizza : System.Web.UI.Page
    {
        // LEGACY PATTERN: Direct instantiation of data access classes
        // MODERNIZATION PATH: Dependency injection with interfaces
        private ToppingRepository _toppingRepository = new ToppingRepository();

        // Base price for custom pizzas (small size)
        private const decimal BASE_PRICE = 8.99m;

        /// <summary>
        /// Page Load event
        /// LEGACY PATTERN: Page lifecycle initialization
        /// MODERNIZATION PATH: OnInitialized in Blazor or OnGet in Razor Pages
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // LEGACY PATTERN: Initialize controls on first load
                // MODERNIZATION NOTE: IsPostBack check is Web Forms specific
                
                LoadToppings();
                UpdatePriceSummary();
            }
        }

        /// <summary>
        /// Load toppings into checkbox list
        /// LEGACY PATTERN: Manual data binding with filtering
        /// MODERNIZATION PATH: LINQ queries with IQueryable or specification pattern
        /// </summary>
        private void LoadToppings()
        {
            try
            {
                List<Topping> toppings;
                string selectedCategory = ToppingCategoryFilter.SelectedValue;
                bool vegetarianOnly = VegetarianOnlyCheckbox.Checked;
                
                // Get toppings based on filters
                // LEGACY PATTERN: Multiple if/else for filtering
                // MODERNIZATION PATH: Query specification pattern or LINQ composition
                
                if (!string.IsNullOrEmpty(selectedCategory))
                {
                    toppings = _toppingRepository.GetByCategory(selectedCategory);
                }
                else
                {
                    toppings = _toppingRepository.GetAll();
                }
                
                if (vegetarianOnly)
                {
                    toppings = toppings.Where(t => t.IsVegetarian).ToList();
                }
                
                // LEGACY PATTERN: DataTextField/DataValueField binding
                // MODERNIZATION PATH: Template-based item rendering
                ToppingsList.DataSource = toppings;
                ToppingsList.DataTextField = "Name";
                ToppingsList.DataValueField = "Id";
                ToppingsList.DataBind();
                
                // Add price information to each item
                // LEGACY PATTERN: Modify list items after binding
                // MODERNIZATION NOTE: Inefficient two-step process
                foreach (ListItem item in ToppingsList.Items)
                {
                    int toppingId = int.Parse(item.Value);
                    var topping = toppings.FirstOrDefault(t => t.Id == toppingId);
                    
                    if (topping != null)
                    {
                        item.Text = $"{topping.Name} (+${topping.Price:F2})";
                        
                        if (topping.IsVegetarian)
                        {
                            item.Text += " 🌱";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // LEGACY PATTERN: Basic error handling
                // MODERNIZATION PATH: Structured logging and user feedback
                System.Diagnostics.Debug.WriteLine($"Error loading toppings: {ex.Message}");
            }
        }

        /// <summary>
        /// Handle topping category filter change
        /// LEGACY PATTERN: AutoPostBack event handler
        /// MODERNIZATION NOTE: Causes postback within UpdatePanel
        /// MODERNIZATION PATH: Client-side filtering or SignalR
        /// </summary>
        protected void ToppingCategoryFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Reload topping on filter change
            // MODERNIZATION NOTE: UpdatePanel provides partial page update
            
            LoadToppings();
            ToppingUpdatePanel.Update();
        }

        /// <summary>
        /// Calculate and update price summary
        /// LEGACY PATTERN: Manual label updates
        /// MODERNIZATION PATH: Computed properties with automatic binding
        /// </summary>
        protected void CalculatePrice_Click(object sender, EventArgs e)
        {
            UpdatePriceSummary();
            PriceSummaryPanel.Update();
        }

        /// <summary>
        /// Update price summary based on selections
        /// LEGACY PATTERN: Imperative UI updates
        /// MODERNIZATION PATH: Reactive/declarative binding
        /// </summary>
        private void UpdatePriceSummary()
        {
            try
            {
                // Get selected size
                string selectedSize = SizeList.SelectedValue ?? "Small";
                SelectedSizeLabel.Text = selectedSize;
                
                // Get selected crust
                string selectedCrust = CrustList.SelectedValue ?? "Thin";
                SelectedCrustLabel.Text = selectedCrust.Replace("Gluten-Free", "Gluten-Free");
                
                // Calculate base price based on size
                // LEGACY PATTERN: Switch statement for multipliers
                // MODERNIZATION PATH: Strategy pattern or lookup table
                decimal sizeMultiplier = 1.0m;
                switch (selectedSize)
                {
                    case "Medium":
                        sizeMultiplier = 1.3m;
                        break;
                    case "Large":
                        sizeMultiplier = 1.6m;
                        break;
                    default:
                        sizeMultiplier = 1.0m;
                        break;
                }
                
                decimal basePrice = BASE_PRICE * sizeMultiplier;
                BasePriceLabel.Text = $"${basePrice:F2}";
                
                // Calculate crust upgrade cost
                // LEGACY PATTERN: Hardcoded upgrade prices
                // MODERNIZATION PATH: Configuration or database lookup
                decimal crustUpgrade = 0m;
                if (selectedCrust == "Stuffed")
                    crustUpgrade = 2.00m;
                else if (selectedCrust == "Gluten-Free")
                    crustUpgrade = 3.00m;
                
                CrustUpgradeLabel.Text = $"${crustUpgrade:F2}";
                
                // Calculate toppings cost
                // LEGACY PATTERN: Loop through checked items
                // MODERNIZATION PATH: LINQ Sum with selected toppings
                decimal toppingsCost = 0m;
                int toppingCount = 0;
                
                foreach (ListItem item in ToppingsList.Items)
                {
                    if (item.Selected)
                    {
                        int toppingId = int.Parse(item.Value);
                        var topping = _toppingRepository.GetById(toppingId);
                        
                        if (topping != null)
                        {
                            toppingsCost += topping.Price;
                            toppingCount++;
                        }
                    }
                }
                
                ToppingCountLabel.Text = toppingCount.ToString();
                ToppingsPriceLabel.Text = $"${toppingsCost:F2}";
                
                // Calculate total
                decimal total = basePrice + crustUpgrade + toppingsCost;
                TotalPriceLabel.Text = $"${total:F2}";
            }
            catch (Exception ex)
            {
                // LEGACY PATTERN: Silent error handling
                // MODERNIZATION PATH: User notification and logging
                System.Diagnostics.Debug.WriteLine($"Error calculating price: {ex.Message}");
            }
        }

        /// <summary>
        /// Handle Add to Cart button click
        /// LEGACY PATTERN: Postback event handler with session manipulation
        /// MODERNIZATION PATH: API call or service method with injected dependencies
        /// </summary>
        protected void AddToCartButton_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate selections
                // LEGACY PATTERN: Manual validation
                // MODERNIZATION PATH: Data annotations or FluentValidation
                
                if (string.IsNullOrEmpty(SizeList.SelectedValue))
                {
                    // Validation will handle this
                    return;
                }
                
                // Get selections
                string size = SizeList.SelectedValue;
                string crust = CrustList.SelectedValue;
                
                // Get selected toppings
                // LEGACY PATTERN: Loop through control items
                // MODERNIZATION PATH: Bound collection of selected items
                List<string> selectedToppings = new List<string>();
                foreach (ListItem item in ToppingsList.Items)
                {
                    if (item.Selected)
                    {
                        // Extract topping name (remove price from text)
                        string toppingName = item.Text;
                        int priceIndex = toppingName.IndexOf(" (+$");
                        if (priceIndex > 0)
                        {
                            toppingName = toppingName.Substring(0, priceIndex);
                        }
                        toppingName = toppingName.Replace(" 🌱", "").Trim();
                        selectedToppings.Add(toppingName);
                    }
                }
                
                // Calculate final price
                UpdatePriceSummary();
                decimal unitPrice = decimal.Parse(TotalPriceLabel.Text.Replace("$", ""));
                
                // Create a custom pizza
                // LEGACY PATTERN: Manual object creation
                // MODERNIZATION PATH: Factory pattern or builder pattern
                var customPizza = new Pizza
                {
                    Id = 0, // Custom pizza
                    Name = "Custom Pizza",
                    Description = $"{size} pizza with {selectedToppings.Count} topping(s)",
                    BasePrice = unitPrice,
                    Category = "Custom",
                    IsPreMade = false
                };
                
                // Create order item
                var orderItem = new OrderItem(customPizza, size, crust, selectedToppings, unitPrice);
                
                // Add to cart (session)
                // LEGACY PATTERN: Direct session manipulation
                // MODERNIZATION PATH: Injected cart service
                var cart = Session["Cart"] as List<OrderItem>;
                if (cart == null)
                {
                    cart = new List<OrderItem>();
                    Session["Cart"] = cart;
                }
                
                // Assign ID
                orderItem.Id = cart.Count > 0 ? cart.Max(i => i.Id) + 1 : 1;
                cart.Add(orderItem);
                Session["Cart"] = cart;
                
                // Redirect to cart
                // LEGACY PATTERN: Server-side redirect
                // MODERNIZATION PATH: Client-side navigation or SPA routing
                Response.Redirect("Cart.aspx");
            }
            catch (Exception ex)
            {
                // LEGACY PATTERN: Basic error logging
                // MODERNIZATION PATH: Structured logging and user notification
                System.Diagnostics.Debug.WriteLine($"Error adding to cart: {ex.Message}");
            }
        }

        /// <summary>
        /// Handle selection change events (for AutoPostBack)
        /// LEGACY PATTERN: Event handler for real-time updates
        /// MODERNIZATION NOTE: Could cause many postbacks
        /// </summary>
        protected void UpdatePrice(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Automatic price update on selection change
            // MODERNIZATION PATH: Reactive binding with automatic updates
            UpdatePriceSummary();
        }

        // LEGACY PATTERN: Many event handlers and manual state management
        // MODERNIZATION NOTE: Code-behind becomes procedural and hard to test
        // MODERNIZATION PATH: Component-based architecture with reactive state
    }
}
