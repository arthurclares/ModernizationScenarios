using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using PizzaShop.WebForms.Models;

// LEGACY PATTERN: Code-behind file tightly coupled to .aspx markup
// MODERNIZATION PATH: Razor Pages with PageModel or Blazor components with code-behind
namespace PizzaShop.WebForms.Pages
{
    public partial class Cart : System.Web.UI.Page
    {
        // LEGACY PATTERN: Session state for cart storage
        // MODERNIZATION PATH: Distributed cache (Redis), database, or client-side storage
        private List<OrderItem> CartItems
        {
            get
            {
                if (Session["Cart"] == null)
                {
                    Session["Cart"] = new List<OrderItem>();
                }
                return (List<OrderItem>)Session["Cart"];
            }
            set
            {
                Session["Cart"] = value;
            }
        }

        // LEGACY PATTERN: Page_Load event handler
        // MODERNIZATION PATH: OnInitializedAsync in Blazor, OnGetAsync in Razor Pages
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCart();
            }
        }

        // Bind cart items to repeater and update UI
        private void BindCart()
        {
            var cart = CartItems;

            if (cart == null || cart.Count == 0)
            {
                // Show empty cart message
                EmptyCartPanel.Visible = true;
                CartItemsPanel.Visible = false;
            }
            else
            {
                // Show cart items
                EmptyCartPanel.Visible = false;
                CartItemsPanel.Visible = true;

                // LEGACY PATTERN: Manual data binding to Repeater control
                // MODERNIZATION PATH: Component-based rendering with automatic binding
                CartRepeater.DataSource = cart;
                CartRepeater.DataBind();

                // Update order summary
                UpdateOrderSummary(cart);
            }

            // Update master page cart badge
            UpdateMasterCartBadge();
        }

        // Calculate and display order summary
        private void UpdateOrderSummary(List<OrderItem> cart)
        {
            // LEGACY PATTERN: Creating Order object just for calculation
            // MODERNIZATION PATH: Use service layer or domain logic for calculations
            var order = new Order
            {
                Items = cart
            };

            SubtotalLabel.Text = order.Subtotal.ToString("F2");
            TaxLabel.Text = order.Tax.ToString("F2");
            DeliveryFeeLabel.Text = order.DeliveryFee.ToString("F2");
            TotalLabel.Text = order.Total.ToString("F2");
        }

        // LEGACY PATTERN: ItemCommand event handler for Repeater
        // MODERNIZATION PATH: Component event handlers or API endpoints
        protected void CartRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int itemIndex = Convert.ToInt32(e.CommandArgument);
            var cart = CartItems;

            if (e.CommandName == "Update")
            {
                // Find the quantity textbox in the repeater item
                TextBox quantityBox = (TextBox)e.Item.FindControl("QuantityTextBox");
                
                // LEGACY PATTERN: Manual parsing and validation
                // MODERNIZATION PATH: Model binding with data annotations
                if (int.TryParse(quantityBox.Text, out int newQuantity))
                {
                    if (newQuantity >= 1 && newQuantity <= 20)
                    {
                        cart[itemIndex].Quantity = newQuantity;
                        CartItems = cart;

                        ShowSuccessMessage($"Quantity updated to {newQuantity}");
                        BindCart();
                    }
                }
            }
            else if (e.CommandName == "Remove")
            {
                // Remove item from cart
                var removedItem = cart[itemIndex];
                cart.RemoveAt(itemIndex);
                CartItems = cart;

                ShowSuccessMessage($"{removedItem.Pizza.Name} removed from cart");
                BindCart();
            }
        }

        // LEGACY PATTERN: Button click event handler with full postback
        // MODERNIZATION PATH: Async API call to process payment
        protected void CheckoutButton_Click(object sender, EventArgs e)
        {
            var cart = CartItems;
            
            if (cart == null || cart.Count == 0)
            {
                return;
            }

            // LEGACY PATTERN: Creating order summary for simulation
            // MODERNIZATION PATH: Call payment gateway API, create order in database
            var order = new Order
            {
                Items = cart,
                OrderDate = DateTime.Now,
                Status = "Pending"
            };

            // Simulate order processing
            // LEGACY PATTERN: Session state manipulation
            // MODERNIZATION PATH: Database transaction with order repository
            Session["LastOrder"] = order;
            Session["Cart"] = new List<OrderItem>(); // Clear cart

            // LEGACY PATTERN: Response.Redirect for navigation
            // MODERNIZATION PATH: NavigationManager in Blazor or RedirectToPage in Razor Pages
            Response.Redirect("~/Pages/Confirmation.aspx", false);
        }

        // Helper method to display toppings for custom pizzas
        // LEGACY PATTERN: Code-behind helper called from aspx markup
        // MODERNIZATION PATH: Component property or display template
        protected string ShowToppings(object dataItem)
        {
            var orderItem = dataItem as OrderItem;
            if (orderItem == null || orderItem.Pizza == null)
            {
                return string.Empty;
            }

            // Check if this is a custom pizza with toppings
            if (orderItem.Pizza.Toppings != null && orderItem.Pizza.Toppings.Any())
            {
                var toppingNames = orderItem.Pizza.Toppings.Select(t => t.Name);
                return $"<div class='toppings-list'><strong>Toppings:</strong> {string.Join(", ", toppingNames)}</div>";
            }

            return string.Empty;
        }

        // Show success message
        private void ShowSuccessMessage(string message)
        {
            SuccessMessageLabel.Text = message;
            SuccessMessagePanel.Visible = true;

            // LEGACY PATTERN: Hide message after delay using client script
            // MODERNIZATION PATH: Toast notification service
            string script = "setTimeout(function() { document.querySelector('.alert-success').style.display = 'none'; }, 3000);";
            ScriptManager.RegisterStartupScript(this, GetType(), "HideMessage", script, true);
        }

        // Update cart badge in master page
        // LEGACY PATTERN: Accessing master page controls directly
        // MODERNIZATION PATH: Shared state management or layout data
        private void UpdateMasterCartBadge()
        {
            var master = this.Master as SiteMaster;
            if (master != null)
            {
                master.UpdateCartBadge();
            }
        }
    }
}
