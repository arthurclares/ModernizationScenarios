# Azure Slice - Local Deployment & Testing Guide

This guide provides step-by-step instructions for running and testing the Azure Slice web application on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software
- **Windows OS** (Windows 10/11 or Windows Server)
- **Visual Studio 2019/2022** (Community, Professional, or Enterprise)
  - OR **Visual Studio Code** with C# extensions
- **.NET Framework 4.7.2 SDK** (or higher)
- **IIS Express** (included with Visual Studio)
- **Modern Web Browser** (Microsoft Edge, Chrome, or Firefox)

### Optional Tools
- **Git** (for version control)
- **Visual Studio Build Tools** (if not using full Visual Studio)

---

## Getting Started

### Option 1: Running with Visual Studio

#### 1. Open the Project

**Using Solution File:**
```powershell
# Navigate to the project directory
cd "c:\Users\arclares\OneDrive - Microsoft\Desktop\FY26\AppMod\ModernizationScenarios\ModernizationScenarios\Old .net PizzaApp"

# Open the solution file
start "Old .net PizzaApp.slnx"
```

**Or manually:**
1. Launch Visual Studio
2. Click **File > Open > Project/Solution**
3. Navigate to: `ModernizationScenarios\Old .net PizzaApp\`
4. Select `Old .net PizzaApp.slnx`
5. Click **Open**

#### 2. Restore NuGet Packages

Visual Studio will automatically restore packages, or manually:
1. Right-click on the solution in **Solution Explorer**
2. Select **Restore NuGet Packages**
3. Wait for restoration to complete

#### 3. Build the Project

**Using Visual Studio:**
1. Press `Ctrl + Shift + B` or
2. Click **Build > Build Solution**
3. Check the **Output** window for any errors

**Expected Output:**
```
Build started...
1>------ Build started: Project: PizzaShop.WebForms, Configuration: Debug Any CPU ------
1>PizzaShop.WebForms -> ...\bin\PizzaShop.WebForms.dll
========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========
```

#### 4. Run the Application

**Method A: Using Debug (Recommended for Development)**
1. Press `F5` or click **Debug > Start Debugging**
2. IIS Express will launch automatically
3. Your default browser will open to the application

**Method B: Without Debugging**
1. Press `Ctrl + F5` or click **Debug > Start Without Debugging**
2. Faster startup, no debugger attached

**Expected Result:**
- IIS Express icon appears in system tray
- Browser opens to: `http://localhost:[port]/Pages/Default.aspx`
- Default port is usually `54321` or assigned automatically

#### 5. Stop the Application

- Close the browser window
- Click **Debug > Stop Debugging** or press `Shift + F5`
- Or right-click IIS Express icon in system tray > **Stop Site**

---

### Option 2: Running with Visual Studio Code

#### 1. Open the Project Folder

```powershell
# Navigate to project directory
cd "c:\Users\arclares\OneDrive - Microsoft\Desktop\FY26\AppMod\ModernizationScenarios\ModernizationScenarios\Old .net PizzaApp\PizzaShop.WebForms"

# Open in VS Code
code .
```

#### 2. Build Using MSBuild

**Locate MSBuild:**
```powershell
# Find MSBuild path
$msbuildPath = Get-ChildItem "C:\Program Files\Microsoft Visual Studio" -Recurse -Filter "MSBuild.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

Write-Host $msbuildPath
```

**Build the Project:**
```powershell
# Build in Debug mode
& $msbuildPath PizzaShop.WebForms.csproj /p:Configuration=Debug /p:Platform=AnyCPU

# Or build in Release mode
& $msbuildPath PizzaShop.WebForms.csproj /p:Configuration=Release /p:Platform=AnyCPU
```

#### 3. Run with IIS Express

**Using PowerShell:**
```powershell
# Stop any existing IIS Express instances
Stop-Process -Name "iisexpress" -ErrorAction SilentlyContinue

# Wait for cleanup
Start-Sleep -Seconds 1

# Navigate to project directory
cd "c:\Users\arclares\OneDrive - Microsoft\Desktop\FY26\AppMod\ModernizationScenarios\ModernizationScenarios\Old .net PizzaApp\PizzaShop.WebForms"

# Start IIS Express on port 54321
Start-Process "C:\Program Files\IIS Express\iisexpress.exe" -ArgumentList "/path:`"$PWD`"","/port:54321"
```

**Access the Application:**
1. Open your browser
2. Navigate to: `http://localhost:54321/Pages/Default.aspx`

**Stop IIS Express:**
```powershell
# Stop all IIS Express processes
Stop-Process -Name "iisexpress" -Force
```

---

### Option 3: Running with IISExpress Command Line

#### Quick Start Script

```powershell
# Quick launch script
$projectPath = "c:\Users\arclares\OneDrive - Microsoft\Desktop\FY26\AppMod\ModernizationScenarios\ModernizationScenarios\Old .net PizzaApp\PizzaShop.WebForms"
$port = 54321

# Stop existing instances
Stop-Process -Name "iisexpress" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Start IIS Express
Push-Location $projectPath
Start-Process "C:\Program Files\IIS Express\iisexpress.exe" -ArgumentList "/path:`"$projectPath`"","/port:$port" -PassThru
Pop-Location

# Open browser
Start-Sleep -Seconds 3
Start-Process "http://localhost:$port/Pages/Default.aspx"
```

#### Custom Port Configuration

To use a different port, modify the command:
```powershell
# Use port 8080 instead
Start-Process "C:\Program Files\IIS Express\iisexpress.exe" -ArgumentList "/path:`"$PWD`"","/port:8080"
```

---

## Testing the Application

### 1. Homepage (Default.aspx)

**URL:** `http://localhost:54321/Pages/Default.aspx`

**What to Test:**
- ✅ Page loads with Azure blue theme
- ✅ "Azure Slice" branding appears in navbar and hero section
- ✅ Three feature cards display correctly (Fresh & Hot, Quality Ingredients, Made with Love)
- ✅ Featured pizzas section loads (3 pizza cards)
- ✅ Navigation menu is functional
- ✅ Footer displays correct information (info@azureslice.cloud)

**Verify:**
- Azure blue (`#0078D4`) navigation bar
- Light blue (`#50E6FF`) accents and badges
- Responsive layout on browser resize

---

### 2. Menu Page (Menu.aspx)

**URL:** `http://localhost:54321/Pages/Menu.aspx`

**What to Test:**
- ✅ All specialty pizzas load in grid layout
- ✅ Category filter dropdown works
- ✅ Pizza cards show name, category badge, description, and price
- ✅ "Add Small" and "Add Medium" buttons are visible
- ✅ Clicking add buttons updates cart count in navbar

**Test Steps:**
1. Select different categories from dropdown (All, Meat Lovers, Vegetarian, etc.)
2. Verify pizzas filter correctly
3. Click "Add Small" on any pizza
4. Check cart badge updates (should show "1")
5. Add more items and verify count increments

**Verify:**
- Azure blue color scheme on cards
- Smooth hover effects on pizza cards
- Category badges use light blue background

---

### 3. Build Your Own Pizza (BuildPizza.aspx)

**URL:** `http://localhost:54321/Pages/BuildPizza.aspx`

**What to Test:**
- ✅ Size selection (Small, Medium, Large)
- ✅ Crust selection dropdown
- ✅ Topping category filter works
- ✅ Individual topping selection
- ✅ "Vegetarian Only" checkbox filters toppings
- ✅ Price summary updates when clicking "Update Price"
- ✅ "Add to Cart" button functions

**Test Steps:**
1. Select "Medium" size
2. Choose "Stuffed Crust"
3. Select several toppings (e.g., Pepperoni, Mushrooms, Extra Cheese)
4. Click "Update Price" button
5. Verify price summary shows:
   - Selected size
   - Selected crust
   - Base price
   - Topping count and price
   - Crust upgrade fee
   - Total price
6. Click "Add to Cart"
7. Verify cart count increments

**Verify:**
- Azure gradient on price summary sidebar
- Blue selection highlights on checked options
- Price calculation accuracy

---

### 4. Shopping Cart (Cart.aspx)

**URL:** `http://localhost:54321/Pages/Cart.aspx`

**What to Test:**
- ✅ All cart items display correctly
- ✅ Item details show (name, size, crust, toppings)
- ✅ Quantity controls work (+/- buttons)
- ✅ "Update" button recalculates totals
- ✅ "Remove" button deletes items
- ✅ Order summary shows correct subtotal
- ✅ "Proceed to Checkout" button works

**Test Steps:**
1. View cart with items from previous tests
2. Try changing quantity on an item
3. Click "Update Quantities"
4. Verify total price updates
5. Click "Remove" on one item
6. Verify item is deleted and total updates
7. Click "Proceed to Checkout"

**Verify:**
- Azure blue color on prices and buttons
- Order summary totals match individual items
- Empty cart message if all items removed

---

### 5. Order Confirmation (Confirmation.aspx)

**URL:** `http://localhost:54321/Pages/Confirmation.aspx`

**What to Test:**
- ✅ Success icon displays (green checkmark)
- ✅ Order number generated
- ✅ Order details shown correctly
- ✅ All ordered items listed
- ✅ Total amount matches cart
- ✅ Estimated delivery time displayed
- ✅ "Order Another Pizza" button returns to menu

**Test Steps:**
1. Complete checkout from cart page
2. Verify confirmation page loads
3. Check that order number is displayed
4. Verify all items from cart appear in order
5. Check total amount
6. Click "Order Another Pizza"
7. Verify navigation to menu page

**Verify:**
- Microsoft green (`#107C10`) success icon
- Clean, professional layout
- All Azure theme colors consistent

---

## Navigation & UI Testing

### Navigation Bar
**Test Each Link:**
- ✅ **Azure Slice** (brand logo) → Default.aspx
- ✅ **Home** → Default.aspx
- ✅ **Menu** → Menu.aspx
- ✅ **Build Your Own** → BuildPizza.aspx
- ✅ **Cart** → Cart.aspx (with item count badge)

**Verify:**
- Active page has highlighted nav item
- Cart badge shows correct count (light blue background)
- Hover states show light blue color
- Mobile responsive (collapse menu on small screens)

### Footer
**Verify Content:**
- ✅ About Us: "Azure Slice - Cloud-powered pizza ordering since 2020"
- ✅ Hours: Correct operating hours
- ✅ Contact: Phone and email (info@azureslice.cloud)
- ✅ Copyright: Current year and "Azure Slice"

---

## Browser Compatibility Testing

Test the application in multiple browsers:

### Microsoft Edge (Recommended)
```powershell
start msedge http://localhost:54321/Pages/Default.aspx
```

### Google Chrome
```powershell
start chrome http://localhost:54321/Pages/Default.aspx
```

### Mozilla Firefox
```powershell
start firefox http://localhost:54321/Pages/Default.aspx
```

**Expected Results:**
- All browsers render consistently
- CSS custom properties (variables) work
- Font Awesome icons display
- Bootstrap 3 grid functions properly

---

## Responsive Design Testing

### Test Different Screen Sizes

1. **Desktop (1920x1080)**
   - 3-column pizza grid
   - Full navigation bar
   - Sticky price summary sidebar

2. **Tablet (768x1024)**
   - 2-column pizza grid
   - Navigation adapts
   - Price summary below builder

3. **Mobile (375x667)**
   - Single column layout
   - Hamburger menu
   - Touch-friendly buttons

**Browser DevTools:**
1. Press `F12` to open Developer Tools
2. Click "Toggle Device Toolbar" (Ctrl+Shift+M)
3. Select different device presets
4. Test all pages at each size

---

## Performance Testing

### Page Load Times
Use browser dev tools to measure:
1. Press `F12` → Network tab
2. Refresh page (`Ctrl+R`)
3. Check total load time

**Expected Performance:**
- **Default.aspx**: < 2 seconds
- **Menu.aspx**: < 3 seconds (data loading)
- **BuildPizza.aspx**: < 2.5 seconds
- **Cart.aspx**: < 1 second
- **Static assets** (CSS, JS): < 500ms

### ViewState Size
1. Right-click page → View Source
2. Search for `__VIEWSTATE`
3. Check hidden field size

**Note:** Large ViewState is expected in Web Forms (legacy pattern)

---

## Troubleshooting

### Common Issues & Solutions

#### Issue: Port Already in Use
**Error:** `Failed to bind to port 54321`

**Solution:**
```powershell
# Find and kill process using port 54321
Get-Process -Id (Get-NetTCPConnection -LocalPort 54321).OwningProcess | Stop-Process -Force

# Or use different port
Start-Process "C:\Program Files\IIS Express\iisexpress.exe" -ArgumentList "/path:`"$PWD`"","/port:8080"
```

#### Issue: Build Errors
**Error:** `CS0246: The type or namespace name could not be found`

**Solution:**
1. Clean the solution:
   ```powershell
   & $msbuildPath PizzaShop.WebForms.csproj /t:Clean
   ```
2. Restore NuGet packages in Visual Studio
3. Rebuild solution

#### Issue: 404 Not Found
**Error:** Page shows "404 - File or directory not found"

**Solution:**
1. Verify you're accessing the correct URL: `/Pages/Default.aspx`
2. Check IIS Express is running (system tray icon)
3. Restart IIS Express
4. Ensure files exist in project directory

#### Issue: CSS Not Loading
**Symptom:** Page displays but no styling

**Solution:**
1. Check browser console (F12) for 404 errors
2. Verify `Content/site.css` exists
3. Hard refresh: `Ctrl+Shift+R`
4. Clear browser cache

#### Issue: Session Lost / Cart Empty
**Symptom:** Cart items disappear after navigation

**Solution:**
- Session state is InProc (lost on app restart)
- Don't stop/restart IIS Express during testing
- This is expected legacy behavior

#### Issue: UpdatePanel Not Working
**Symptom:** Price doesn't update on BuildPizza page

**Solution:**
1. Check browser console for JavaScript errors
2. Ensure jQuery and ASP.NET AJAX scripts load
3. Verify ScriptManager in Site.Master
4. Check that UpdatePanel triggers are configured

---

## Advanced Testing

### Load Testing (Optional)

**Using Browser:**
1. Open 5-10 browser tabs
2. Navigate to different pages
3. Add items to cart simultaneously
4. Verify session isolation

**Note:** For real load testing, use tools like:
- Apache JMeter
- k6
- Azure Load Testing

### Security Testing

**Basic Checks:**
1. Try SQL injection in search/filter fields
2. Test XSS in input fields
3. Verify ViewState encryption (if enabled)
4. Check for exposed error messages

**Note:** This is a demo app, not production-hardened

---

## Development Workflow

### Making Changes

1. **Edit Files**
   - Modify `.aspx`, `.aspx.cs`, or `.css` files
   - Save changes

2. **See Changes**
   - CSS/JavaScript: Just refresh browser (Ctrl+R)
   - Code-behind (.cs): Stop debugging, rebuild (Ctrl+Shift+B), restart (F5)
   - Markup (.aspx): Usually just refresh

3. **Debug**
   - Set breakpoints in .cs files (click left margin)
   - Press F5 to start debugging
   - Step through code: F10 (step over), F11 (step into)

### Hot Reload (Visual Studio 2022)

Visual Studio 2022 supports hot reload:
1. Start debugging (F5)
2. Make changes to code
3. Save file
4. Changes apply automatically (for supported scenarios)

---

## Quick Reference Commands

### Start Application (PowerShell)
```powershell
cd "c:\Users\arclares\OneDrive - Microsoft\Desktop\FY26\AppMod\ModernizationScenarios\ModernizationScenarios\Old .net PizzaApp\PizzaShop.WebForms"
Stop-Process -Name "iisexpress" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Start-Process "C:\Program Files\IIS Express\iisexpress.exe" -ArgumentList "/path:`"$PWD`"","/port:54321" -PassThru
Start-Sleep -Seconds 3
Start-Process "http://localhost:54321/Pages/Default.aspx"
```

### Stop Application
```powershell
Stop-Process -Name "iisexpress" -Force
```

### Build Project
```powershell
$msbuildPath = Get-ChildItem "C:\Program Files\Microsoft Visual Studio" -Recurse -Filter "MSBuild.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
& $msbuildPath PizzaShop.WebForms.csproj /p:Configuration=Debug
```

### Clean Build
```powershell
& $msbuildPath PizzaShop.WebForms.csproj /t:Clean
& $msbuildPath PizzaShop.WebForms.csproj /p:Configuration=Debug
```

---

## Testing Checklist

Use this checklist to verify all functionality:

### Visual Theme
- [ ] Azure blue navbar (#0078D4)
- [ ] Light blue accents and badges (#50E6FF)
- [ ] Microsoft green success states (#107C10)
- [ ] "Azure Slice" branding throughout
- [ ] Consistent color scheme across all pages

### Functionality
- [ ] Homepage loads with featured pizzas
- [ ] Menu filtering by category works
- [ ] Build Your Own pizza creation works
- [ ] Cart add/update/remove operations work
- [ ] Checkout process completes successfully
- [ ] Order confirmation displays

### Navigation
- [ ] All nav links work
- [ ] Cart badge updates correctly
- [ ] Active page highlighted
- [ ] Footer links are correct

### Responsive
- [ ] Desktop layout (3 columns)
- [ ] Tablet layout (2 columns)
- [ ] Mobile layout (1 column)
- [ ] Touch-friendly on mobile

### Cross-Browser
- [ ] Works in Edge
- [ ] Works in Chrome
- [ ] Works in Firefox

---

## Support & Resources

### Documentation
- **Project README**: `README.md`
- **Implementation Plan**: `IMPLEMENTATION_PLAN.md`
- **Page Documentation**: `Pages/README.md`

### External Resources
- [ASP.NET Web Forms Documentation](https://docs.microsoft.com/aspnet/web-forms/)
- [IIS Express Documentation](https://docs.microsoft.com/iis/extensions/introduction-to-iis-express/)
- [Bootstrap 3 Documentation](https://getbootstrap.com/docs/3.3/)

---

## Next Steps

After successful local testing:
1. **Deploy to Azure App Service** (see deployment guide)
2. **Set up CI/CD pipeline** (Azure DevOps or GitHub Actions)
3. **Configure monitoring** (Application Insights)
4. **Plan modernization** (migrate to ASP.NET Core or Blazor)

---

**Last Updated**: February 18, 2026
**Application Version**: Azure Slice v1.0 (Azure-themed)
**Framework**: ASP.NET Web Forms 4.7.2
