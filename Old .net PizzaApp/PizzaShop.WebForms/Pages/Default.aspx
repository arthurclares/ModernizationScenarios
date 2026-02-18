<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PizzaShop.WebForms.Pages.Default" %>

<!--
    LEGACY PATTERN: ASP.NET Web Forms page directive with Master Page
    MODERNIZATION PATH: Razor Page or Blazor component
-->

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hero Section -->
    <div class="jumbotron" style="background: linear-gradient(135deg, #d32f2f 0%, #b71c1c 100%); color: white; border-radius: 8px;">
        <h1 class="display-3">
            <i class="fa fa-pizza-slice"></i> Welcome to Artisan Pizza Shop
        </h1>
        <p class="lead">
            Handcrafted, authentic pizzas made with fresh ingredients and baked to perfection.
        </p>
        <hr class="my-4" style="border-color: rgba(255,255,255,0.3);" />
        <p>
            Choose from our delicious pre-made pizzas or build your own masterpiece!
        </p>
        <p class="lead">
            <!--
                LEGACY PATTERN: asp:HyperLink server control for navigation
                MODERNIZATION NOTE: Could usestandard <a> tags
            -->
            <asp:HyperLink ID="btnViewMenu" runat="server" NavigateUrl="~/Pages/Menu.aspx" 
                CssClass="btn btn-warning btn-lg" role="button">
                <i class="fa fa-list"></i> View Menu
            </asp:HyperLink>
            <asp:HyperLink ID="btnBuildPizza" runat="server" NavigateUrl="~/Pages/BuildPizza.aspx" 
                CssClass="btn btn-success btn-lg" role="button" style="margin-left: 10px;">
                <i class="fa fa-plus-circle"></i> Build Your Own
            </asp:HyperLink>
        </p>
    </div>

    <!-- Features Section -->
    <div class="row" style="margin-top: 40px;">
        <div class="col-md-4">
            <div class="text-center" style="padding: 20px;">
                <i class="fa fa-fire" style="font-size: 48px; color: #d32f2f; margin-bottom: 15px;"></i>
                <h3>Fresh & Hot</h3>
                <p>
                    Our pizzas are made fresh to order and baked in our traditional stone oven 
                    for that perfect crispy crust.
                </p>
            </div>
        </div>
        <div class="col-md-4">
            <div class="text-center" style="padding: 20px;">
                <i class="fa fa-leaf" style="font-size: 48px; color: #4caf50; margin-bottom: 15px;"></i>
                <h3>Quality Ingredients</h3>
                <p>
                    We use only the finest locally-sourced ingredients, from farm-fresh vegetables 
                    to premium meats and artisan cheeses.
                </p>
            </div>
        </div>
        <div class="col-md-4">
            <div class="text-center" style="padding: 20px;">
                <i class="fa fa-heart" style="font-size: 48px; color: #e91e63; margin-bottom: 15px;"></i>
                <h3>Made with Love</h3>
                <p>
                    Every pizza is crafted with care by our experienced pizza chefs who are 
                    passionate about creating the perfect pie.
                </p>
            </div>
        </div>
    </div>

    <!-- Featured Pizzas Section -->
    <div style="margin-top: 50px;">
        <h2 class="page-header">
            <i class="fa fa-star"></i> Featured Pizzas
        </h2>
        
        <div class="row">
            <!--
                LEGACY PATTERN: asp:Repeater for data binding
                MODERNIZATION PATH: Razor foreach or Blazor @foreach with components
            -->
            <asp:Repeater ID="FeaturedPizzasRepeater" runat="server">
                <ItemTemplate>
                    <div class="col-md-4">
                        <div class="pizza-card">
                            <div class="pizza-card-img">
                                <i class="fa fa-pizza-slice"></i>
                            </div>
                            <div class="pizza-card-body">
                                <!--
                                    LEGACY PATTERN: <%# Eval("Property") %> databinding syntax
                                    MODERNIZATION PATH: Razor @Model.Property or Blazor @item.Property
                                -->
                                <h3 class="pizza-card-title"><%# Eval("Name") %></h3>
                                <span class="pizza-card-category"><%# Eval("Category") %></span>
                                <p class="pizza-card-description"><%# Eval("Description") %></p>
                                <div class="pizza-card-price">
                                    Starting at $<%# String.Format("{0:F2}", Eval("BasePrice")) %>
                                </div>
                                <div class="pizza-card-footer">
                                    <!--
                                        LEGACY PATTERN: Navigate to Menu page for ordering
                                        MODERNIZATION NOTE: Could use AJAX to add to cart directly
                                    -->
                                    <asp:HyperLink ID="orderLink" runat="server" NavigateUrl="~/Pages/Menu.aspx" 
                                        CssClass="btn btn-pizza">
                                        <i class="fa fa-shopping-cart"></i> Order Now
                                    </asp:HyperLink>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <!-- Call to Action -->
    <div style="margin-top: 50px; margin-bottom: 50px; text-align: center; padding: 40px; background-color: #fff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <h2 style="color: #d32f2f; margin-bottom: 20px;">
            Ready to Order?
        </h2>
        <p style="font-size: 18px; color: #666; margin-bottom: 30px;">
            Browse our full menu or create your perfect custom pizza today!
        </p>
        <asp:HyperLink ID="ctaMenu" runat="server" NavigateUrl="~/Pages/Menu.aspx" 
            CssClass="btn btn-pizza btn-lg" style="margin-right: 15px;">
            <i class="fa fa-list"></i> Full Menu
        </asp:HyperLink>
        <asp:HyperLink ID="ctaBuild" runat="server" NavigateUrl="~/Pages/BuildPizza.aspx" 
            CssClass="btn btn-pizza-outline btn-lg">
            <i class="fa fa-plus-circle"></i> Build Custom Pizza
        </asp:HyperLink>
    </div>

    <!--
        LEGACY PATTERN: Inline styles throughout
        MODERNIZATION NOTE: Use CSS classes for better maintainability
        MODERNIZATION PATH: Component-scoped styles or CSS modules
    -->
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="scripts" runat="server">
    <!-- Page-specific scripts if needed -->
</asp:Content>
