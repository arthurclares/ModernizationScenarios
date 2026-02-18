<%@ Page Title="Build Your Pizza" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BuildPizza.aspx.cs" Inherits="PizzaShop.WebForms.Pages.BuildPizza" %>

<!--
    LEGACY PATTERN: Web Forms page with complex server controls
    MODERNIZATION PATH: Blazor component with two-way binding
-->

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-header">
        <i class="fa fa-plus-circle"></i> Build Your Own Pizza
    </h1>

    <div class="row">
        <div class="col-md-8">
            <!-- Size Selection -->
            <div class="builder-section">
                <h3><i class="fa fa-circle"></i> Step 1: Choose Your Size</h3>
                 <!--
                    LEGACY PATTERN: RadioButtonList server control
                    MODERNIZATION PATH: Radio group with component binding
                -->
                <asp:RadioButtonList ID="SizeList" runat="server" 
                    RepeatLayout="UnorderedList" CssClass="size-options"
                    AutoPostBack="false" OnSelectedIndexChanged="UpdatePrice">
                    <asp:ListItem Value="Small" Selected="True">Small (10") - Base Price</asp:ListItem>
                    <asp:ListItem Value="Medium">Medium (12") - +30%</asp:ListItem>
                    <asp:ListItem Value="Large">Large (14") - +60%</asp:ListItem>
                </asp:RadioButtonList>
                <!--
                    LEGACY PATTERN: RequiredFieldValidator for validation
                    MODERNIZATION PATH: Data annotations or FluentValidation
                -->
                <asp:RequiredFieldValidator ID="SizeValidator" runat="server" 
                    ControlToValidate="SizeList"
                    ErrorMessage="Please select a size" 
                    CssClass="text-danger"
                    Display="Dynamic">
                </asp:RequiredFieldValidator>
            </div>

            <!-- Crust Selection -->
            <div class="builder-section">
                <h3><i class="fa fa-bread-slice"></i> Step 2: Choose Your Crust</h3>
                <!--
                    LEGACY PATTERN: DropDownList control
                    MODERNIZATION PATH: Select element with binding
                -->
                <asp:DropDownList ID="CrustList" runat="server" CssClass="form-control" 
                    AutoPostBack="false" OnSelectedIndexChanged="UpdatePrice">
                    <asp:ListItem Value="Thin" Selected="True">Thin Crust</asp:ListItem>
                    <asp:ListItem Value="Regular">Regular Crust</asp:ListItem>
                    <asp:ListItem Value="Thick">Thick Crust</asp:ListItem>
                    <asp:ListItem Value="Stuffed">Stuffed Crust (+$2.00)</asp:ListItem>
                    <asp:ListItem Value="Gluten-Free">Gluten-Free (+$3.00)</asp:ListItem>
                </asp:DropDownList>
            </div>

            <!-- Topping Selection -->
            <div class="builder-section">
                <h3><i class="fa fa-pepper-hot"></i> Step 3: Select Your Toppings</h3>
                <p class="text-muted">Each topping adds to the total price. Choose as many as you like!</p>
                
                <!--
                    LEGACY PATTERN: UpdatePanel for partial page updates
                    MODERNIZATION NOTE: AJAX Control Toolkit required
                    MODERNIZATION PATH: SignalR or client-side state management
                -->
                <asp:UpdatePanel ID="ToppingUpdatePanel" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <!-- Category Tabs (simulated with filter) -->
                        <div style="margin-bottom: 20px;">
                            <label style="font-weight: bold; margin-right: 10px;">Filter:</label>
                            <asp:DropDownList ID="ToppingCategoryFilter" runat="server" 
                                CssClass="form-control" style="display: inline-block; width: auto;"
                                AutoPostBack="true" OnSelectedIndexChanged="ToppingCategoryFilter_SelectedIndexChanged">
                                <asp:ListItem Value="" Selected="True">All Toppings</asp:ListItem>
                                <asp:ListItem Value="Meat">Meats</asp:ListItem>
                                <asp:ListItem Value="Vegetable">Vegetables</asp:ListItem>
                                <asp:ListItem Value="Cheese">Cheeses</asp:ListItem>
                            </asp:DropDownList>
                            
                            <asp:CheckBox ID="VegetarianOnlyCheckbox" runat="server" 
                                Text=" Vegetarian Only" 
                                AutoPostBack="true" 
                                OnCheckedChanged="ToppingCategoryFilter_SelectedIndexChanged"
                                style="margin-left: 20px;" />
                        </div>
                        
                        <!-- Toppings CheckBoxList -->
                        <!--
                            LEGACY PATTERN: CheckBoxList in UpdatePanel for AJAX updates
                            MODERNIZATION PATH: Checkbox components with state binding
                        -->
                        <asp:CheckBoxList ID="ToppingsList" runat="server" 
                            RepeatLayout="UnorderedList"
                            CssClass="topping-grid"
                            DataTextField="Name"
                            DataValueField="Id"
                            AutoPostBack="false">
                        </asp:CheckBoxList>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>

            <!-- Add to Cart Button -->
            <div class="builder-section">
                <!--
                    LEGACY PATTERN: asp:Button for postback submit
                    MODERNIZATION PATH: onclick event or form submit with API call
                -->
                <asp:Button ID="AddToCartButton" runat="server" 
                    Text="Add to Cart" 
                    CssClass="btn btn-pizza btn-lg btn-block" 
                    OnClick="AddToCartButton_Click">
                    <i class="fa fa-shopping-cart"></i> Add to Cart
                </asp:Button>
            </div>
        </div>

        <div class="col-md-4">
            <!-- Price Summary (Sticky Sidebar) -->
            <div class="price-summary">
                <h3><i class="fa fa-calculator"></i> Your Pizza</h3>
                
                <!--
                    LEGACY PATTERN: UpdatePanel for dynamic price updates
                    MODERNIZATION NOTE: Triggers partial postback
                    MODERNIZATION PATH: Real-time calculation with JavaScript or SignalR
                -->
                <asp:UpdatePanel ID="PriceSummaryPanel" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="price-row">
                            <span>Size:</span>
                            <asp:Label ID="SelectedSizeLabel" runat="server" Text="Small"></asp:Label>
                        </div>
                        <div class="price-row">
                            <span>Crust:</span>
                            <asp:Label ID="SelectedCrustLabel" runat="server" Text="Thin"></asp:Label>
                        </div>
                        <div class="price-row">
                            <span>Base Price:</span>
                            <asp:Label ID="BasePriceLabel" runat="server" Text="$8.99"></asp:Label>
                        </div>
                        <div class="price-row">
                            <span>Toppings (<asp:Label ID="ToppingCountLabel" runat="server" Text="0"></asp:Label>):</span>
                            <asp:Label ID="ToppingsPriceLabel" runat="server" Text="$0.00"></asp:Label>
                        </div>
                        <div class="price-row">
                            <span>Crust Upgrade:</span>
                            <asp:Label ID="CrustUpgradeLabel" runat="server" Text="$0.00"></asp:Label>
                        </div>
                        <div class="price-row total">
                            <span>Total:</span>
                            <asp:Label ID="TotalPriceLabel" runat="server" Text="$8.99"></asp:Label>
                        </div>
                        
                        <!-- Calculate Price Button -->
                        <asp:Button ID="CalculatePriceButton" runat="server" 
                            Text="Update Price" 
                            CssClass="btn btn-warning btn-block" 
                            OnClick="CalculatePrice_Click"
                            style="margin-top: 20px;">
                            <i class="fa fa-refresh"></i> Update Price
                        </asp:Button>
                    </ContentTemplate>
                    <Triggers>
                        <!--
                            LEGACY PATTERN: UpdatePanel triggers for async postbacks
                            MODERNIZATION NOTE: Complex trigger configuration
                        -->
                        <asp:AsyncPostBackTrigger ControlID="CalculatePriceButton" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
                
                <div style="margin-top: 30px; padding-top: 20px; border-top: 2px solid rgba(255,255,255,0.3);">
                    <p style="font-size: 12px; opacity: 0.8;">
                        <i class="fa fa-info-circle"></i> Click "Update Price" to see your total
                    </p>
                </div>
            </div>
        </div>
    </div>

    <!--
        LEGACY PATTERN: ViewState stores all control state
        MODERNIZATION NOTE: Large ViewState impacts page size
        MODERNIZATION PATH: Stateless design or distributed cache
    -->
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="scripts" runat="server">
    <script type="text/javascript">
        // LEGACY PATTERN: jQuery for client-side enhancement
        // MODERNIZATION PATH: Modern JavaScript or framework
        
        $(document).ready(function() {
            // Add visual feedback for topping selection
            // LEGACY PATTERN: DOM manipulation with jQuery
            
            $('input[type="checkbox"]').change(function() {
                $(this).closest('.topping-item').toggleClass('selected', this.checked);
            });
            
            // Show loading during UpdatePanel postbacks
            // LEGACY PATTERN: PageRequestManager for UpdatePanel events
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            
            if (prm) {
                prm.add_beginRequest(function() {
                    $('#CalculatePriceButton').prop('disabled', true).text('Calculating...');
                });
                
                prm.add_endRequest(function() {
                    setTimeout(function() {
                        $('#CalculatePriceButton').prop('disabled', false).html('<i class="fa fa-refresh"></i> Update Price');
                    }, 500);
                });
            }
        });
    </script>
</asp:Content>
