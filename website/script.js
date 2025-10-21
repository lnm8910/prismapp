// Parallax scrolling effect for hero section
document.addEventListener('DOMContentLoaded', function() {
    const hero = document.querySelector('.hero');
    const logo = document.querySelector('.logo');
    const heroTitle = document.querySelector('.hero h1');
    const heroTagline = document.querySelector('.tagline');
    const heroSubtitle = document.querySelector('.subtitle');
    const heroCta = document.querySelector('.cta');

    // Throttle function for better performance
    function throttle(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    // Parallax scroll handler
    function handleParallax() {
        const scrolled = window.pageYOffset;
        const heroHeight = hero.offsetHeight;

        // Only apply parallax while hero is in view
        if (scrolled <= heroHeight) {
            // Calculate parallax factors
            const parallaxFactor = scrolled * 0.5;
            const opacityFactor = 1 - (scrolled / heroHeight);
            const scaleFactor = 1 - (scrolled / heroHeight) * 0.1;

            // Apply parallax transformations
            if (logo) {
                logo.style.transform = `translateY(${parallaxFactor * 0.3}px) scale(${scaleFactor})`;
                logo.style.opacity = opacityFactor;
            }

            if (heroTitle) {
                heroTitle.style.transform = `translateY(${parallaxFactor * 0.5}px)`;
                heroTitle.style.opacity = opacityFactor;
            }

            if (heroTagline) {
                heroTagline.style.transform = `translateY(${parallaxFactor * 0.6}px)`;
                heroTagline.style.opacity = opacityFactor;
            }

            if (heroSubtitle) {
                heroSubtitle.style.transform = `translateY(${parallaxFactor * 0.7}px)`;
                heroSubtitle.style.opacity = opacityFactor;
            }

            if (heroCta) {
                heroCta.style.transform = `translateY(${parallaxFactor * 0.8}px)`;
                heroCta.style.opacity = opacityFactor;
            }

            // Parallax for hero background gradient
            if (hero) {
                hero.style.backgroundPosition = `center ${parallaxFactor * 0.2}px`;
            }
        }
    }

    // Smooth scroll reveal for sections
    function revealOnScroll() {
        const reveals = document.querySelectorAll('.feature, .tech-item, .roadmap-item');

        reveals.forEach(element => {
            const elementTop = element.getBoundingClientRect().top;
            const elementVisible = 100;

            if (elementTop < window.innerHeight - elementVisible) {
                element.classList.add('active');
            }
        });
    }

    // Add scroll event listener with throttling
    window.addEventListener('scroll', throttle(function() {
        handleParallax();
        revealOnScroll();
    }, 10));

    // Initial check
    handleParallax();
    revealOnScroll();

    // Add smooth scroll for navigation
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});
