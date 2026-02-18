using System;
using System.Linq;
using PizzaShop.WebForms.Models;

// LEGACY PATTERN: Code-behind file for confirmation page
// MODERNIZATION PATH: Razor Pages with PageModel or Blazor component
namespace PizzaShop.WebForms.Pages
{
    public partial class Confirmation : System.Web.UI.Page
    {
        // LEGACY PATTERN: Page_Load event handler
        // MODERNIZATION PATH: OnInitializedAsync in Blazor, OnGetAsync in Razor Pages
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadOrderConfirmation();
            }
        }

        private void LoadOrderConfirmation()
        {
            // LEGACY PATTERN: Retrieving order from Session
            // MODERNIZATION PATH: Retrieve from database using order ID from route parameter
            Order order = Session["LastOrder"] as Order;

            if (order == null || order.Items == null || order.Items.Count == 0)
            {
                // No order found
                NoOrderPanel.Visible = true;
                OrderConfirmationPanel.Visible = false;
                return;
            }

            // Show order confirmation
            NoOrderPanel.Visible = false;
            OrderConfirmationPanel.Visible = true;

            // LEGACY PATTERN: Generating order number from timestamp
            // MODERNIZATION PATH: Database-generated order ID or GUID
            OrderNumberLabel.Text = $"#{order.OrderDate.ToString("yyyyMMddHHmmss")}";
            OrderDateLabel.Text = order.OrderDate.ToString("MMMM dd, yyyy 'at' h:mm tt");
            
            // Calculate estimated delivery time (30-45 minutes from now)
            var deliveryTime = DateTime.Now.AddMinutes(30);
            DeliveryTimeLabel.Text = deliveryTime.ToString("h:mm tt") + " - " + 
                                    deliveryTime.AddMinutes(15).ToString("h:mm tt");

            // Bind order items
            // LEGACY PATTERN: Manual data binding to Repeater
            // MODERNIZATION PATH: Component-based rendering with automatic binding
            OrderItemsRepeater.DataSource = order.Items;
            OrderItemsRepeater.DataBind();

            // Display order summary
            SubtotalLabel.Text = order.Subtotal.ToString("F2");
            TaxLabel.Text = order.Tax.ToString("F2");
            DeliveryFeeLabel.Text = order.DeliveryFee.ToString("F2");
            TotalLabel.Text = order.Total.ToString("F2");

            // LEGACY PATTERN: Clear the order from session after displaying
            // MODERNIZATION PATH: Order persisted in database, session only holds order ID
            Session.Remove("LastOrder");
        }

        // Helper method to display toppings for custom pizzas
        // LEGACY PATTERN: Code-behind helper called from aspx markup
        // MODERNIZATION PATH: Component property or display template
        protected string ShowItemToppings(object dataItem)
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
                return $"<div class='item-toppings'>Toppings: {string.Join(", ", toppingNames)}</div>";
            }

            return string.Empty;
        }
    }
}
