<%@ Page Title="Menu" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Menu.aspx.cs" Inherits="PizzaShop.WebForms.Pages.Menu" %>

<!--
    LEGACY PATTERN: ASP.NET Web Forms page with Master Page
    MODERNIZATION PATH: Razor Page with layout or Blazor component
-->

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-header">
        <i class="fa fa-list"></i> Our Menu
    </h1>
    
    <!-- Category Filter -->
    <div style="margin-bottom: 30px; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <div class="row">
            <div class="col-md-12">
                <label style="font-weight: bold; margin-right: 15px;">Filter by Category:</label>
                <!--
                    LEGACY PATTERN: asp:DropDownList server control with AutoPostBack
                    MODERNIZATION NOTE: Causes full page postback on selection change
                    MODERNIZATION PATH: Client-side filtering with JavaScript or AJAX
                -->
                <asp:DropDownList ID="CategoryFilter" runat="server product" AutoPostBack="True" 
                    OnSelectedIndexChanged="CategoryFilter_SelectedIndexChanged" 
                    CssClass="form-control" style="display: inline-block; width: auto; min-width: 200px;">
                </asp:DropDownList>
            </div>
        </div>
    </div>

    <!-- Pizza Grid -->
    <div class="row">
        <!--
            LEGACY PATTERN: asp:Repeater for data-bound list rendering
            MODERNIZATION PATH: Razor @foreach or Blazor @foreach with components
        -->
        <asp:Repeater ID="PizzaRepeater" runat="server" OnItemCommand="PizzaRepeater_ItemCommand">
            <ItemTemplate>
                <div class="col-md-4">
                    <div class="pizza-card">
                        <!-- Pizza Image Placeholder -->
                        <div class="pizza-card-img">
                            <i class="fa fa-pizza-slice"></i>
                        </div>
                        
                        <div class="pizza-card-body">
                            <!--
                                LEGACY PATTERN: Eval() for one-way databinding
                                MODERNIZATION PATH: @Model.Property or @item.Property
                            -->
                            <h3 class="pizza-card-title"><%# Eval("Name") %></h3>
                            <span class="pizza-card-category"><%# Eval("Category") %></span>
                            <p class="pizza-card-description"><%# Eval("Description") %></p>
                            
                            <div class="pizza-card-price">
                                $<%# String.Format("{0:F2}", Eval("BasePrice")) %>
                                <small style="font-size: 14px; color: #666; font-weight: normal;">(Small)</small>
                            </div>
                            
                            <div class="pizza-card-footer" style="margin-top: 15px;">
                                <!--
                                    LEGACY PATTERN: asp:LinkButton with CommandArgument for postback events
                                    MODERNIZATION NOTE: Causes server-side postback
                                    MODERNIZATION PATH: AJAX call or client-side state management
                                -->
                                <asp:LinkButton ID="AddToCartSmall" runat="server" 
                                    CssClass="btn btn-pizza btn-sm" 
                                    CommandName="AddToCart"
                                    CommandArgument='<%# Eval("Id") + "|Small" %>'>
                                    <i class="fa fa-shopping-cart"></i> Add Small
                                </asp:LinkButton>
                                
                                <asp:LinkButton ID="AddToCartMedium" runat="server" 
                                    CssClass="btn btn-pizza btn-sm" 
                                    CommandName="AddToCart"
                                    CommandArgument='<%# Eval("Id") + "|Medium" %>'
                                    style="margin-left: 5px;">
                                    <i class="fa fa-shopping-cart"></i> Add Medium
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <!-- No Results Message -->
    <asp:Panel ID="NoResultsPanel" runat="server" Visible="false" CssClass="text-center" style="padding: 60px 20px; background: white; border-radius: 8px; margin-top: 20px;">
        <i class="fa fa-search" style="font-size: 64px; color: #ccc; margin-bottom: 20px;"></i>
        <h3 style="color: #999;">No pizzas found in this category</h3>
        <p style="color: #999;">Try selecting a different category or build your own pizza!</p>
        <asp:HyperLink ID="BuildPizzaLink" runat="server" NavigateUrl="~/Pages/BuildPizza.aspx" 
            CssClass="btn btn-pizza">
            <i class="fa fa-plus-circle"></i> Build Your Own Pizza
        </asp:HyperLink>
    </asp:Panel>

    <!--
        LEGACY PATTERN: ViewState maintains control state across postbacks
        MODERNIZATION NOTE: Creates large hidden field in HTML
        MODERNIZATION PATH: Client-side state or API calls
    -->
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="scripts" runat="server">
    <script type="text/javascript">
        // LEGACY PATTERN: jQuery for client-side enhancements
        // MODERNIZATION PATH: Modern JavaScript or framework-specific code
        
        $(document).ready(function() {
            // Smooth scroll animation when pizza is added
            // LEGACY PATTERN: Global JavaScript functions
            
            // Show success message when item added (if needed)
            var urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('added') === '1') {
                // Simple alert for legacy pattern
                // MODERNIZATION PATH: Toast notifications or snackbar components
                setTimeout(function() {
                    alert('Pizza added to cart!');
                }, 100);
            }
        });
    </script>
</asp:Content>
