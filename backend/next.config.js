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
	images: {
		remotePatterns: [
			{
				protocol: 'https',
				hostname: 'dewwodfpevclnvdrhmnt.supabase.co',
			},
		],
	},
}

module.exports = nextConfig
