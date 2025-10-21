# Prism Website

This folder contains the static website for prismapp.dev.

## Files

- `index.html` - Main landing page
- `style.css` - Styles and responsive design
- `logo.png` - Prism logo (triangular prism with gradient)
- `favicon.png` - Website favicon (512x512 app icon)
- `.htaccess` - Apache configuration for HTTPS, caching, and security

## Deployment to Namecheap cPanel

### Option 1: File Manager Upload

1. Log in to your Namecheap account
2. Go to cPanel for your hosting account
3. Open **File Manager**
4. Navigate to `public_html` (or the root directory for prismapp.dev)
5. Upload all files from this `website` folder:
   - `index.html`
   - `style.css`
   - `logo.png`
   - `favicon.png`
   - `.htaccess`
6. Ensure file permissions are set correctly (644 for files, 755 for directories)
7. Visit https://prismapp.dev to verify

### Option 2: FTP Upload

1. Get your FTP credentials from Namecheap cPanel
2. Use an FTP client (FileZilla, Cyberduck, etc.)
3. Connect to your hosting server
4. Navigate to `public_html` directory
5. Upload all files from this `website` folder
6. Visit https://prismapp.dev to verify

## File Structure on Server

Your `public_html` directory should look like:

```
public_html/
├── .htaccess
├── index.html
├── style.css
├── logo.png
└── favicon.png
```

## SSL/HTTPS

Make sure SSL is enabled in your Namecheap cPanel:
1. Go to cPanel → SSL/TLS Status
2. Enable AutoSSL or install Let's Encrypt certificate
3. Force HTTPS redirect via .htaccess if needed

## Testing

After deployment, test:
- Homepage loads: https://prismapp.dev
- Styles are applied correctly
- Favicon appears in browser tab
- Responsive design works on mobile
- All links work (GitHub links)

## Local Testing

To test locally before deployment:
1. Open `index.html` directly in a browser
2. Or use a local server:
   ```bash
   # Python 3
   python3 -m http.server 8000

   # Then visit http://localhost:8000
   ```

## Updates

To update the website:
1. Edit files in this folder
2. Re-upload changed files to cPanel
3. Clear browser cache to see changes

## Support

For issues with the website, open an issue on the [GitHub repository](https://github.com/lnm8910/prismapp).
