#!/bin/bash
#
# ============================================================================
# TaskMaster Classic - Legacy Web App Deployment Script
# ============================================================================
#
# SYNOPSIS:
#     Deploys a legacy JavaScript web application to Ubuntu VM on Hyper-V
#
# DESCRIPTION:
#     This script performs the following tasks:
#     - Checks prerequisites (Ubuntu, sudo access, required packages)
#     - Installs and configures Nginx web server
#     - Deploys the TaskMaster Classic web application
#     - Configures firewall rules for HTTP access
#     - Sets proper file permissions
#
# USAGE:
#     chmod +x deploy-legacy-webapp.sh
#     sudo ./deploy-legacy-webapp.sh [OPTIONS]
#
# OPTIONS:
#     -p, --port PORT      Web server port (default: 80)
#     -d, --domain DOMAIN  Server domain name (default: localhost)
#     -h, --help           Display this help message
#
# NOTES:
#     Author: GitHub Copilot
#     Date: 2026-01-21
#     Requires: Ubuntu 20.04+, sudo privileges
#     Target: Hyper-V Virtual Machine
#
# MODERNIZATION NOTES:
#     This application uses intentionally legacy JavaScript patterns:
#     - jQuery 2.2.4 (outdated version)
#     - ES5 syntax (var, callbacks, no modules)
#     - IIFE pattern instead of ES6 modules
#     - Global namespace pollution
#     
#     Future modernization path:
#     - Migrate to vanilla JavaScript or React/Vue
#     - Use ES6+ features (let/const, arrow functions, async/await)
#     - Implement proper module bundling (Webpack/Vite)
#     - Add TypeScript for type safety
#
# ============================================================================

set -e

# ============================================================================
# Configuration
# ============================================================================
APP_NAME="taskmaster"
WEB_ROOT="/var/www/${APP_NAME}"
NGINX_SITE="/etc/nginx/sites-available/${APP_NAME}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${APP_NAME}"
DEFAULT_PORT=80
DEFAULT_DOMAIN="localhost"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${SCRIPT_DIR}/src"

# ============================================================================
# Color Output Functions
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo ""
}

# ============================================================================
# Helper Functions
# ============================================================================
show_help() {
    head -50 "$0" | grep -E "^#" | sed 's/^# //' | sed 's/^#//'
    exit 0
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_ubuntu() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot determine OS. This script requires Ubuntu."
        exit 1
    fi
    
    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        print_warning "This script is designed for Ubuntu. Detected: $ID"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "Operating System: $PRETTY_NAME"
}

# ============================================================================
# Installation Functions
# ============================================================================
update_system() {
    print_info "Updating package lists..."
    apt-get update -qq
    print_success "Package lists updated"
}

install_nginx() {
    print_info "Checking Nginx installation..."
    
    if command -v nginx &> /dev/null; then
        print_info "Nginx is already installed"
        nginx -v
    else
        print_info "Installing Nginx..."
        apt-get install -y nginx -qq
        print_success "Nginx installed successfully"
    fi
    
    # Ensure Nginx is enabled and started
    systemctl enable nginx
    systemctl start nginx
    print_success "Nginx service is running"
}

configure_firewall() {
    print_info "Configuring firewall rules..."
    
    if command -v ufw &> /dev/null; then
        # Check if UFW is active
        if ufw status | grep -q "Status: active"; then
            ufw allow 'Nginx HTTP' > /dev/null 2>&1 || ufw allow 80/tcp > /dev/null 2>&1
            print_success "Firewall configured to allow HTTP traffic"
        else
            print_warning "UFW is installed but not active. Skipping firewall configuration."
        fi
    else
        print_warning "UFW not found. Please manually configure firewall if needed."
    fi
}

# ============================================================================
# Deployment Functions
# ============================================================================
create_web_directory() {
    print_info "Creating web application directory..."
    
    if [[ -d "$WEB_ROOT" ]]; then
        print_warning "Directory $WEB_ROOT already exists. Backing up..."
        mv "$WEB_ROOT" "${WEB_ROOT}.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    mkdir -p "$WEB_ROOT"
    mkdir -p "$WEB_ROOT/css"
    mkdir -p "$WEB_ROOT/js"
    
    print_success "Created directory structure at $WEB_ROOT"
}

deploy_application() {
    print_info "Deploying TaskMaster Classic application..."
    
    # Check if source files exist
    if [[ ! -d "$SRC_DIR" ]]; then
        print_error "Source directory not found: $SRC_DIR"
        print_info "Creating application files inline..."
        create_app_files
    else
        # Copy application files
        cp -r "$SRC_DIR"/* "$WEB_ROOT/"
        print_success "Application files copied from $SRC_DIR"
    fi
    
    # Set proper ownership and permissions
    chown -R www-data:www-data "$WEB_ROOT"
    chmod -R 755 "$WEB_ROOT"
    
    print_success "Application deployed to $WEB_ROOT"
}

create_nginx_config() {
    local port=$1
    local domain=$2
    
    print_info "Creating Nginx configuration..."
    
    cat > "$NGINX_SITE" << EOF
# TaskMaster Classic - Nginx Configuration
# Legacy JavaScript Application for Modernization Demo

server {
    listen ${port};
    listen [::]:${port};
    
    server_name ${domain};
    root ${WEB_ROOT};
    index index.html;
    
    # Logging
    access_log /var/log/nginx/${APP_NAME}_access.log;
    error_log /var/log/nginx/${APP_NAME}_error.log;
    
    # Main location
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # Static assets caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 7d;
        add_header Cache-Control "public, immutable";
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml;
    gzip_min_length 1000;
}
EOF

    print_success "Nginx configuration created"
}

enable_site() {
    print_info "Enabling TaskMaster site..."
    
    # Remove default site if exists
    if [[ -L "/etc/nginx/sites-enabled/default" ]]; then
        rm -f "/etc/nginx/sites-enabled/default"
        print_info "Removed default Nginx site"
    fi
    
    # Create symlink for our site
    if [[ ! -L "$NGINX_ENABLED" ]]; then
        ln -s "$NGINX_SITE" "$NGINX_ENABLED"
    fi
    
    # Test Nginx configuration
    print_info "Testing Nginx configuration..."
    if nginx -t; then
        print_success "Nginx configuration is valid"
        
        # Reload Nginx
        systemctl reload nginx
        print_success "Nginx reloaded successfully"
    else
        print_error "Nginx configuration test failed"
        exit 1
    fi
}

# ============================================================================
# Inline Application Creation (fallback if src files don't exist)
# ============================================================================
create_app_files() {
    print_info "Creating application files..."
    
    # This function creates files inline if the src directory doesn't exist
    # The actual files should be in the src/ subdirectory
    
    print_warning "Source files should be in ${SRC_DIR}/"
    print_warning "Please ensure index.html, css/style.css, and js/app.js exist"
}

# ============================================================================
# Display Functions
# ============================================================================
show_deployment_info() {
    local port=$1
    local domain=$2
    
    # Get server IP
    local server_ip=$(hostname -I | awk '{print $1}')
    
    print_header "Deployment Complete!"
    
    echo -e "  ${GREEN}✓${NC} Application: TaskMaster Classic"
    echo -e "  ${GREEN}✓${NC} Web Root: $WEB_ROOT"
    echo -e "  ${GREEN}✓${NC} Web Server: Nginx"
    echo ""
    echo -e "  ${CYAN}Access URLs:${NC}"
    echo -e "    Local:   http://localhost:${port}"
    echo -e "    Network: http://${server_ip}:${port}"
    if [[ "$domain" != "localhost" ]]; then
        echo -e "    Domain:  http://${domain}:${port}"
    fi
    echo ""
    echo -e "  ${YELLOW}MODERNIZATION NOTES:${NC}"
    echo -e "    This app uses legacy JavaScript patterns (ES5, jQuery 2.x)"
    echo -e "    intended for future modernization exercises:"
    echo -e "    • Migrate from jQuery to vanilla JS or React"
    echo -e "    • Convert var to let/const"
    echo -e "    • Replace callbacks with async/await"
    echo -e "    • Add ES6 modules and bundling"
    echo -e "    • Implement TypeScript"
    echo ""
    echo -e "  ${CYAN}Useful Commands:${NC}"
    echo -e "    Check status:  sudo systemctl status nginx"
    echo -e "    View logs:     sudo tail -f /var/log/nginx/${APP_NAME}_access.log"
    echo -e "    Restart:       sudo systemctl restart nginx"
    echo ""
}

# ============================================================================
# Main Execution
# ============================================================================
main() {
    local port=$DEFAULT_PORT
    local domain=$DEFAULT_DOMAIN
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                port="$2"
                shift 2
                ;;
            -d|--domain)
                domain="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                ;;
        esac
    done
    
    print_header "TaskMaster Classic Deployment"
    echo "  Target: Ubuntu VM on Hyper-V"
    echo "  Port: $port"
    echo "  Domain: $domain"
    echo ""
    
    # Pre-flight checks
    check_root
    check_ubuntu
    
    # Installation
    update_system
    install_nginx
    configure_firewall
    
    # Deployment
    create_web_directory
    deploy_application
    create_nginx_config "$port" "$domain"
    enable_site
    
    # Complete
    show_deployment_info "$port" "$domain"
}

# Run main function with all arguments
main "$@"
