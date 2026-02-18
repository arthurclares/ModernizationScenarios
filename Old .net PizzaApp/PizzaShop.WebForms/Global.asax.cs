using System;
using System.Web;
using System.Web.Routing;

namespace PizzaShop.WebForms
{
    /// <summary>
    /// Global application class for handling application-level events
    /// LEGACY PATTERN: Global.asax for application lifecycle management
    /// MODERNIZATION PATH: Program.cs with minimal hosting model in ASP.NET Core
    /// </summary>
    public class Global : HttpApplication
    {
        /// <summary>
        /// Application start event - fires once when application first starts
        /// LEGACY PATTERN: Application_Start for initialization
        /// MODERNIZATION NOTE: No dependency injection, direct initialization
        /// </summary>
        protected void Application_Start(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Manual route registration (if using Routing)
            // In this Web Forms app, we rely on file-based routing (.aspx files)
            
            // Initialize application-level data if needed
            // MODERNIZATION NOTE: In modern .NET, this would be done in Program.cs
            // with proper service registration and DI container setup
            
            System.Diagnostics.Debug.WriteLine("PizzaShop Application Started");
        }

        /// <summary>
        /// Session start event - fires for each new user session
        /// LEGACY PATTERN: Session_Start creates server-side session
        /// MODERNIZATION NOTE: Sessions don't scale horizontally without distributed cache
        /// </summary>
        protected void Session_Start(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Initialize session state for shopping cart
            // MODERNIZATION PATH: Use distributed cache (Redis) or stateless tokens
            
            // Initialize empty shopping cart in session
            Session["Cart"] = new System.Collections.Generic.List<Models.OrderItem>();
            
            System.Diagnostics.Debug.WriteLine($"New Session Started: {Session.SessionID}");
        }

        /// <summary>
        /// Application begin request event - fires for every HTTP request
        /// LEGACY PATTERN: Global request handling
        /// MODERNIZATION PATH: Middleware pipeline in ASP.NET Core
        /// </summary>
        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Request processing in Global.asax
            // Could add logging, authentication checks, etc. here
            // MODERNIZATION NOTE: Use middleware for cross-cutting concerns
        }

        /// <summary>
        /// Application error event - global error handler
        /// LEGACY PATTERN: Centralized error handling in Global.asax
        /// MODERNIZATION PATH: Exception handling middleware with structured logging
        /// </summary>
        protected void Application_Error(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Basic error logging
            Exception exception = Server.GetLastError();
            
            if (exception != null)
            {
                // LEGACY PATTERN: Basic logging to debug output
                // MODERNIZATION PATH: Structured logging with ILogger and Application Insights
                System.Diagnostics.Debug.WriteLine($"Application Error: {exception.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack Trace: {exception.StackTrace}");
                
                // In production, would log to file or monitoring service
            }
        }

        /// <summary>
        /// Session end event - fires when session times out or is abandoned
        /// LEGACY PATTERN: Session_End for cleanup
        /// MODERNIZATION NOTE: Only works with InProc session mode
        /// </summary>
        protected void Session_End(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Session cleanup
            // MODERNIZATION NOTE: This event doesn't fire with StateServer or SQLServer mode
            
            System.Diagnostics.Debug.WriteLine($"Session Ended: {Session.SessionID}");
        }

        /// <summary>
        /// Application end event - fires when application shuts down
        /// LEGACY PATTERN: Application_End for cleanup
        /// MODERNIZATION PATH: IHostApplicationLifetime in ASP.NET Core
        /// </summary>
        protected void Application_End(object sender, EventArgs e)
        {
            // LEGACY PATTERN: Cleanup on application shutdown
            // MODERNIZATION NOTE: Not reliable for cleanup in web farms or cloud deployments
            
            System.Diagnostics.Debug.WriteLine("PizzaShop Application Ended");
        }
    }
}
