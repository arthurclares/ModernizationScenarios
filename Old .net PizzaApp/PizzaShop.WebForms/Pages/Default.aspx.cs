using System;
using System.Linq;
using System.Web.UI;
using PizzaShop.WebForms.Data;
using PizzaShop.WebForms.Models;

namespace PizzaShop.WebForms.Pages
{
    /// <summary>
    /// Home page code-behind
    /// LEGACY PATTERN: Code-behind with direct repository instantiation
    /// MODERNIZATION PATH: Razor Pages with dependency injection
    /// </summary>
    public partial class Default : System.Web.UI.Page
    {
        // LEGACY PATTERN: Direct instantiation of repository
        // MODERNIZATION NOTE: No dependency injection
        // MODERNIZATION PATH: Constructor injection with IPizzaRepository
        private PizzaRepository _pizzaRepository = new PizzaRepository();

        /// <summary>
        /// Page Load event handler
        /// LEGACY PATTERN: Page lifecycle event
        /// MODERNIZATION PATH: OnGet() in Razor Pages or OnInitialized() in Blazor
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Check IsPostBack to avoid re-binding on postback
            // MODERNIZATION NOTE: Not needed in modern frameworks with proper state management
            
            if (!IsPostBack)
            {
                BindFeaturedPizzas();
            }
        }

        /// <summary>
        /// Bind featured pizzas to the repeater control
        /// LEGACY PATTERN: Manual data binding to server control
        /// MODERNIZATION PATH: Razor foreach or Blazor component binding
        /// </summary>
        private void BindFeaturedPizzas()
        {
            // LEGACY PATTERN: Synchronous data access
            // MODERNIZATION PATH: async/await with GetFeaturedPizzasAsync()
            
            try
            {
                // Get all pre-made pizzas
                var allPizzas = _pizzaRepository.GetAllPremadePizzas();
                
                // Select top 3 featured pizzas (Specialty category for variety)
                // LEGACY PATTERN: LINQ to Objects query
                var featuredPizzas = allPizzas
                    .Where(p => p.Category == "Specialty")
                    .Take(3)
                    .ToList();
                
                // If not enough specialty pizzas, fill with others
                if (featuredPizzas.Count < 3)
                {
                    var remaining = allPizzas
                        .Where(p => !featuredPizzas.Contains(p))
                        .Take(3 - featuredPizzas.Count);
                    
                    featuredPizzas.AddRange(remaining);
                }
                
                // LEGACY PATTERN: Set DataSource and call DataBind()
                // MODERNIZATION PATH: Model binding or component parameters
                FeaturedPizzasRepeater.DataSource = featuredPizzas;
                FeaturedPizzasRepeater.DataBind();
            }
            catch (Exception ex)
            {
                // LEGACY PATTERN: Basic exception handling
                // MODERNIZATION PATH: Structured logging with ILogger and telemetry
                
                System.Diagnostics.Debug.WriteLine($"Error loading featured pizzas: {ex.Message}");
                
                // Could display error message to user
                // MODERNIZATION NOTE: Use proper error pages or components
            }
        }

        // LEGACY PATTERN: Code-behind class tightly coupled to .aspx markup
        // MODERNIZATION NOTE: Separation of concerns is difficult
        // MODERNIZATION PATH:
        // - Razor Pages: PageModel with dependency injection
        // - Blazor: Component with @inject directive
        // - MVC: Controller with ViewModels
        
        // Example Modern Equivalent (Blazor):
        // @inject IPizzaRepository PizzaRepository
        // @code {
        //     private List<Pizza> featuredPizzas;
        //     
        //     protected override async Task OnInitializedAsync()
        //     {
        //         featuredPizzas = await PizzaRepository.GetFeaturedPizzasAsync();
        //     }
        // }
    }
}
