<%@ Page Title="Order Confirmation" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Confirmation.aspx.cs" Inherits="PizzaShop.WebForms.Pages.Confirmation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="confirmation-page">
        <%-- LEGACY PATTERN: Panel visibility for conditional rendering --%>
        <%-- MODERNIZATION PATH: Component conditional rendering (@if in Blazor) --%>
        <asp:Panel ID="NoOrderPanel" runat="server" Visible="false" CssClass="no-order-message">
            <i class="fa fa-exclamation-triangle fa-3x"></i>
            <h2>No Order Found</h2>
            <p>We couldn't find your order. Please try placing a new order.</p>
            <asp:HyperLink ID="BackToMenuLink" runat="server" NavigateUrl="~/Pages/Menu.aspx" CssClass="btn btn-primary btn-lg">
                Back to Menu
            </asp:HyperLink>
        </asp:Panel>

        <asp:Panel ID="OrderConfirmationPanel" runat="server" Visible="false">
            <div class="confirmation-header">
                <div class="success-icon">
                    <i class="fa fa-check-circle"></i>
                </div>
                <h1>Order Confirmed!</h1>
                <p class="lead">Thank you for your order. Your delicious pizzas are being prepared!</p>
            </div>

            <div class="order-details-section">
                <div class="order-info-box">
                    <h3>Order Information</h3>
                    <div class="info-row">
                        <span class="info-label">Order Number:</span>
                        <span class="info-value"><strong><asp:Label ID="OrderNumberLabel" runat="server" /></strong></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Order Date:</span>
                        <span class="info-value"><asp:Label ID="OrderDateLabel" runat="server" /></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Est. Delivery Time:</span>
                        <span class="info-value"><asp:Label ID="DeliveryTimeLabel" runat="server" /></span>
                    </div>
                </div>

                <div class="order-items-box">
                    <h3>Your Order</h3>
                    <%-- LEGACY PATTERN: Repeater for displaying order items --%>
                    <%-- MODERNIZATION PATH: Component iterators or templates --%>
                    <asp:Repeater ID="OrderItemsRepeater" runat="server">
                        <ItemTemplate>
                            <div class="confirmation-item">
                                <div class="item-name-qty">
                                    <strong><%# Eval("Quantity") %>x</strong> <%# Eval("Pizza.Name") %> (<%# Eval("Size") %>)
                                </div>
                                <div class="item-price">
                                    $<%# Eval("TotalPrice", "{0:F2}") %>
                                </div>
                            </div>
                            <%# ShowItemToppings(Container.DataItem) %>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="order-summary-box">
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
                </div>
            </div>

            <div class="confirmation-actions">
                <asp:HyperLink ID="OrderAnotherLink" runat="server" NavigateUrl="~/Pages/Menu.aspx" CssClass="btn btn-primary btn-lg">
                    <i class="fa fa-shopping-cart"></i> Order More Pizzas
                </asp:HyperLink>
                <asp:HyperLink ID="HomeLink" runat="server" NavigateUrl="~/Pages/Default.aspx" CssClass="btn btn-default btn-lg">
                    <i class="fa fa-home"></i> Back to Home
                </asp:HyperLink>
            </div>

            <div class="delivery-info">
                <div class="alert alert-info">
                    <i class="fa fa-info-circle"></i>
                    <strong>Delivery Instructions:</strong> Your order will be delivered to the address on file. 
                    You will receive a confirmation email shortly with tracking information.
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>
