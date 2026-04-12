/** @type {import('next').NextConfig} */
const nextConfig = {
	experimental: {
		// Keep heavy scraping deps in Node runtime instead of bundling with SWC.
		serverComponentsExternalPackages: [
			'puppeteer-core',
			'@sparticuz/chromium',
			'cheerio',
			'undici',
		],
	},
}

module.exports = nextConfig
