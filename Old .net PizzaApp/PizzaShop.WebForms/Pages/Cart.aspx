<%@ Page Title="Shopping Cart" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Cart.aspx.cs" Inherits="PizzaShop.WebForms.Pages.Cart" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="cart-page">
        <h1>Your Shopping Cart</h1>
        
        <!-- LEGACY PATTERN: ScriptManager required for UpdatePanel -->
        <!-- MODERNIZATION PATH: SignalR or Blazor for real-time updates -->
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        
        <!-- LEGACY PATTERN: UpdatePanel for partial page updates -->
        <!-- MODERNIZATION PATH: Client-side state management with React/Vue/Blazor -->
        <asp:UpdatePanel ID="CartUpdatePanel" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <!-- Empty Cart Message -->
                <asp:Panel ID="EmptyCartPanel" runat="server" Visible="false" CssClass="empty-cart-message">
                    <i class="fa fa-shopping-cart fa-3x"></i>
                    <h2>Your cart is empty</h2>
                    <p>Add some delicious pizzas to get started!</p>
                    <asp:HyperLink ID="BrowseMenuLink" runat="server" NavigateUrl="~/Pages/Menu.aspx" CssClass="btn btn-primary btn-lg">
                        Browse Our Menu
                    </asp:HyperLink>
                </asp:Panel>
                
                <!-- Cart Items -->
                <asp:Panel ID="CartItemsPanel" runat="server" Visible="false">
                    <div class="cart-items-section">
                        <!-- LEGACY PATTERN: Repeater control for data binding -->
                        <!-- MODERNIZATION PATH: Component-based rendering (Blazor) or client-side templating -->
                        <asp:Repeater ID="CartRepeater" runat="server" OnItemCommand="CartRepeater_ItemCommand">
                            <ItemTemplate>
                                <div class="cart-item">
                                    <div class="cart-item-details">
                                        <h3><%# Eval("Pizza.Name") %></h3>
                                        <p class="pizza-description"><%# Eval("Pizza.Description") %></p>
                                        <div class="pizza-meta">
                                            <span class="badge"><%# Eval("Size") %></span>
                                            <%# ShowToppings(Container.DataItem) %>
                                        </div>
                                        <div class="item-price">
                                            $<%# Eval("UnitPrice", "{0:F2}") %> each
                                        </div>
                                    </div>
                                    
                                    <div class="cart-item-actions">
                                        <div class="quantity-control">
                                            <label>Qty:</label>
                                            <!-- LEGACY PATTERN: TextBox server control with validation -->
                                            <!-- MODERNIZATION PATH: HTML5 input with client-side validation -->
                                            <asp:TextBox ID="QuantityTextBox" runat="server" 
                                                Text='<%# Eval("Quantity") %>' 
                                                CssClass="form-control quantity-input"
                                                TextMode="Number" />
                                            <asp:RangeValidator ID="QuantityValidator" runat="server"
                                                ControlToValidate="QuantityTextBox"
                                                MinimumValue="1"
                                                MaximumValue="20"
                                                Type="Integer"
                                                ErrorMessage="Qty must be 1-20"
                                                CssClass="text-danger"
                                                Display="Dynamic"
                                                ValidationGroup='<%# "Item" + Container.ItemIndex %>' />
                                            
                                            <!-- LEGACY PATTERN: CommandName/CommandArgument pattern for item operations -->
                                            <!-- MODERNIZATION PATH: Event handlers with strongly-typed parameters -->
                                            <asp:LinkButton ID="UpdateButton" runat="server" 
                                                CommandName="Update" 
                                                CommandArgument='<%# Container.ItemIndex %>'
                                                CssClass="btn btn-sm btn-default"
                                                ValidationGroup='<%# "Item" + Container.ItemIndex %>'>
                                                <i class="fa fa-refresh"></i> Update
                                            </asp:LinkButton>
                                        </div>
                                        
                                        <div class="item-total">
                                            <strong>$<%# Eval("TotalPrice", "{0:F2}") %></strong>
                                        </div>
                                        
                                        <asp:LinkButton ID="RemoveButton" runat="server" 
                                            CommandName="Remove" 
                                            CommandArgument='<%# Container.ItemIndex %>'
                                            CssClass="btn btn-sm btn-danger"
                                            OnClientClick="return confirm('Remove this item from your cart?');">
                                            <i class="fa fa-trash"></i> Remove
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    
                    <!-- Order Summary -->
                    <div class="order-summary-section">
                        <div class="order-summary">
                            <h3>Order Summary</h3>
                            
                            <div class="summary-row">
                                <span>Subtotal:</span>
                                <span>$<asp:Label ID="SubtotalLabel" runat="server" /></span>
                            </div>
                            
                            <div class="summary-row">
                                <span>Tax (8%):</span>
                                <span>$<asp:Label ID="TaxLabel" runat="server" /></span>
                            </div>
                            
                            <div class="summary-row">
                                <span>Delivery Fee:</span>
                                <span>$<asp:Label ID="DeliveryFeeLabel" runat="server" /></span>
                            </div>
                            
                            <hr />
                            
                            <div class="summary-row total-row">
                                <strong>Total:</strong>
                                <strong class="total-amount">$<asp:Label ID="TotalLabel" runat="server" /></strong>
                            </div>
                            
                            <div class="checkout-actions">
                                <asp:HyperLink ID="ContinueShoppingLink" runat="server" 
                                    NavigateUrl="~/Pages/Menu.aspx" 
                                    CssClass="btn btn-default btn-block">
                                    <i class="fa fa-arrow-left"></i> Continue Shopping
                                </asp:HyperLink>
                                
                                <!-- LEGACY PATTERN: Button postback for checkout -->
                                <!-- MODERNIZATION PATH: API call to payment gateway with async handling -->
                                <asp:Button ID="CheckoutButton" runat="server" 
                                    Text="Proceed to Checkout" 
                                    CssClass="btn btn-success btn-block btn-lg"
                                    OnClick="CheckoutButton_Click" />
                            </div>
                        </div>
                    </div>
                </asp:Panel>
                
                <!-- Success Message -->
                <asp:Panel ID="SuccessMessagePanel" runat="server" Visible="false" CssClass="alert alert-success">
                    <i class="fa fa-check-circle"></i> <asp:Label ID="SuccessMessageLabel" runat="server" />
                </asp:Panel>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
