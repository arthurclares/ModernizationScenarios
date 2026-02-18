using System;
using System.Collections.Generic;
using System.Web.UI;
using PizzaShop.WebForms.Models;

namespace PizzaShop.WebForms
{
    /// <summary>
    /// Code-behind for Site Master page
    /// LEGACY PATTERN: Code-behind with direct session access
    /// MODERNIZATION PATH: Razor layout with dependency injection
    /// </summary>
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        /// <summary>
        /// Page Load event - fires on every page request
        /// LEGACY PATTERN: Page lifecycle event handling
        /// MODERNIZATION NOTE: OnInitialized in Blazor or constructor in MVC
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Check IsPostBack to avoid unnecessary work
            // MODERNIZATION NOTE: Not needed in modern SPA frameworks
            
            if (!IsPostBack)
            {
                UpdateCartBadge();
            }
        }

        /// <summary>
        /// Updates the cart item count badge in navigation
        /// LEGACY PATTERN: Direct session access for cart data
        /// MODERNIZATION PATH: Injected cart service or state management
        /// </summary>
        public void UpdateCartBadge()
        {
            // LEGACY PATTERN: Session state access
            // MODERNIZATION NOTE: Sessions don't work well in distributed/cloud environments
            // MODERNIZATION PATH: Use distributed cache (Redis) or stateless approach
            
            try
            {
                if (Session["Cart"] != null)
                {
                    var cart = Session["Cart"] as List<OrderItem>;
                    
                    if (cart != null)
                    {
                        // Calculate total number of items (considering quantities)
                        int totalItems = 0;
                        foreach (var item in cart)
                        {
                            totalItems += item.Quantity;
                        }
                        
                        // Update badge text
                        // LEGACY PATTERN: Direct manipulation of server control
                        cartCount.InnerText = totalItems.ToString();
                        
                        // MODERNIZATION NOTE: In Blazor, would use data binding
                        // In Razor + JS, would update via AJAX call
                    }
                    else
                    {
                        cartCount.InnerText = "0";
                    }
                }
                else
                {
                    // Initialize cart if it doesn't exist
                    // LEGACY PATTERN: Defensive initialization
                    Session["Cart"] = new List<OrderItem>();
                    cartCount.InnerText = "0";
                }
            }
            catch (Exception ex)
            {
                // LEGACY PATTERN: Basic exception handling
                // MODERNIZATION PATH: Structured logging with ILogger
                System.Diagnostics.Debug.WriteLine($"Error updating cart badge: {ex.Message}");
                cartCount.InnerText = "0";
            }
        }

        /// <summary>
        /// Pre-render event - fires just before page renders
        /// LEGACY PATTERN: Page lifecycle event for last-minute updates
        /// MODERNIZATION NOTE: Not needed in modern frameworks
        /// </summary>
        protected void Page_PreRender(object sender, EventArgs e)
        {
            // Could refresh cart count here to ensure it's current
            // LEGACY PATTERN: Multiple page lifecycle events
            // MODERNIZATION PATH: Component lifecycle methods are simpler
        }

        // LEGACY PATTERN: Code-behind tightly coupled to markup
        // MODERNIZATION NOTE: Master pages replaced by Layout pages (Razor) or layouts (Blazor)
        // MODERNIZATION PATH:
        // - Blazor: <MainLayout> component with @Body and navigation components
        // - Razor Pages: _Layout.cshtml with @RenderBody()
        // - Both support better separation of concerns and testability
    }
}
