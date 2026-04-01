import axios from 'axios'
import * as cheerio from 'cheerio'
import puppeteer from 'puppeteer-core'
import chromium from '@sparticuz/chromium'

export interface InstagramStats {
  username: string
  full_name: string | null
  bio: string | null
  profile_pic_url: string | null
  followers_count: number | null
  following_count: number | null
  posts_count: number | null
  is_private: boolean
  is_verified: boolean
  avg_likes: number | null
  avg_comments: number | null
  engagement_rate: number | null
  highest_video_views: number | null
  avg_video_views: number | null
  recent_posts: RecentPost[]
}

export interface RecentPost {
  type: 'image' | 'video' | 'reel'
  thumbnail_url: string | null
  likes: number | null
  comments: number | null
  views: number | null
  timestamp: string | null
}

export async function scrapeInstagramProfile(username: string): Promise<InstagramStats> {
  const normalizedUsername = username.trim().replace(/^@+/, '')

  try {
    const jsonStats = await fetchViaJsonEndpoint(normalizedUsername)
    if (jsonStats) return jsonStats
  } catch {
    console.log('Instagram JSON endpoint failed, trying browser...')
  }

  try {
    const browserStats = await fetchViaBrowser(normalizedUsername)
    if (browserStats) return browserStats
  } catch (error) {
    console.error('Instagram browser scrape failed:', error)
  }

  throw new Error(`Could not fetch stats for @${normalizedUsername}`)
}

async function fetchViaJsonEndpoint(username: string): Promise<InstagramStats | null> {
  const url = `https://www.instagram.com/${username}/?__a=1&__d=dis`

  const response = await fetch(url, {
    headers: {
      'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15',
      Accept: 'application/json',
      'X-IG-App-ID': '936619743392459',
      Cookie: '',
    },
    signal: AbortSignal.timeout(10000),
  })

  if (!response.ok) return null

  const payload = (await response.json()) as any
  return parseInstagramPayload(payload, username)
}

async function fetchViaBrowser(username: string): Promise<InstagramStats | null> {
  const executablePath =
    process.env.CHROMIUM_EXECUTABLE_PATH || (await chromium.executablePath().catch(() => null))

  if (!executablePath) {
    return fetchViaAxiosHtml(username)
  }

  let browser: Awaited<ReturnType<typeof puppeteer.launch>> | null = null

  try {
    browser = await puppeteer.launch({
      args: chromium.args,
      executablePath,
      headless: true,
    })

    const page = await browser.newPage()

    await page.setUserAgent(
      'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1'
    )

    let capturedPayload: any = null

    page.on('response', async (response) => {
      const responseUrl = response.url()
      if (!responseUrl.includes('api/v1/users/web_profile_info') && !responseUrl.includes('graphql/query')) {
        return
      }

      try {
        const text = await response.text()
        const json = JSON.parse(text)
        if (json?.data?.user || json?.graphql?.user) {
          capturedPayload = json
        }
      } catch {
        // Ignore parse failures on irrelevant responses.
      }
    })

    await page.goto(`https://www.instagram.com/${username}/`, {
      waitUntil: 'networkidle2',
      timeout: 20000,
    })

    await new Promise((resolve) => setTimeout(resolve, 2000))

    if (capturedPayload) {
      return parseInstagramPayload(capturedPayload, username)
    }

    const html = await page.content()
    return parseInstagramHtmlFallback(html, username)
  } finally {
    if (browser) {
      await browser.close()
    }
  }
}

async function fetchViaAxiosHtml(username: string): Promise<InstagramStats | null> {
  const url = `https://www.instagram.com/${username}/`

  const response = await axios.get<string>(url, {
    timeout: 10000,
    headers: {
      'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15',
    },
    validateStatus: () => true,
  })

  if (response.status < 200 || response.status >= 300) return null

  return parseInstagramHtmlFallback(response.data, username)
}

function parseInstagramPayload(payload: any, username: string): InstagramStats | null {
  const user = payload?.graphql?.user || payload?.data?.user
  if (!user) return null

  const recentPosts: RecentPost[] = []
  const edges = (user.edge_owner_to_timeline_media?.edges || []) as any[]

  let totalLikes = 0
  let totalComments = 0
  let totalViews = 0
  let videoCount = 0
  let highestViews = 0

  for (const edge of edges.slice(0, 12)) {
    const node = edge?.node || {}
    const isVideo = Boolean(node.is_video)
    const views = parseCount(node.video_view_count)
    const likes = parseCount(node.edge_media_preview_like?.count)
    const comments = parseCount(node.edge_media_to_comment?.count)

    totalLikes += likes
    totalComments += comments

    if (isVideo) {
      totalViews += views
      videoCount += 1
      if (views > highestViews) highestViews = views
    }

    recentPosts.push({
      type: isVideo ? (node.product_type === 'clips' ? 'reel' : 'video') : 'image',
      thumbnail_url: node.thumbnail_src || node.display_url || null,
      likes,
      comments,
      views: isVideo ? views : null,
      timestamp: node.taken_at_timestamp
        ? new Date(Number(node.taken_at_timestamp) * 1000).toISOString()
        : null,
    })
  }

  const measuredPostCount = recentPosts.length || 1
  const followers = parseCount(user.edge_followed_by?.count)
  const avgLikes = Math.round(totalLikes / measuredPostCount)
  const avgComments = Math.round(totalComments / measuredPostCount)

  const engagementRate =
    followers > 0 ? Number((((avgLikes + avgComments) / followers) * 100).toFixed(2)) : 0

  return {
    username,
    full_name: user.full_name || null,
    bio: user.biography || null,
    profile_pic_url: user.profile_pic_url_hd || user.profile_pic_url || null,
    followers_count: followers,
    following_count: parseOptionalCount(user.edge_follow?.count),
    posts_count: parseOptionalCount(user.edge_owner_to_timeline_media?.count),
    is_private: Boolean(user.is_private),
    is_verified: Boolean(user.is_verified),
    avg_likes: avgLikes,
    avg_comments: avgComments,
    engagement_rate: engagementRate,
    highest_video_views: highestViews > 0 ? highestViews : null,
    avg_video_views: videoCount > 0 ? Math.round(totalViews / videoCount) : null,
    recent_posts: recentPosts,
  }
}

function parseInstagramHtmlFallback(html: string, username: string): InstagramStats | null {
  const $ = cheerio.load(html)
  const description = $('meta[property="og:description"]').attr('content') || ''
  const fullName = $('meta[property="og:title"]').attr('content') || null
  const profilePic = $('meta[property="og:image"]').attr('content') || null

  const countMatch = description.match(/([\d,.]+)\sFollowers,\s([\d,.]+)\sFollowing,\s([\d,.]+)\sPosts/i)

  const followers = countMatch ? parseAbbreviatedCount(countMatch[1]) : null
  const following = countMatch ? parseAbbreviatedCount(countMatch[2]) : null
  const posts = countMatch ? parseAbbreviatedCount(countMatch[3]) : null

  if (followers == null && following == null && posts == null) {
    return null
  }

  return {
    username,
    full_name: fullName,
    bio: null,
    profile_pic_url: profilePic,
    followers_count: followers,
    following_count: following,
    posts_count: posts,
    is_private: /private/i.test(description),
    is_verified: /verified/i.test(description),
    avg_likes: null,
    avg_comments: null,
    engagement_rate: null,
    highest_video_views: null,
    avg_video_views: null,
    recent_posts: [],
  }
}

function parseCount(value: unknown): number {
  if (typeof value === 'number' && Number.isFinite(value)) return Math.round(value)
  if (typeof value === 'string') return parseAbbreviatedCount(value) ?? 0
  return 0
}

function parseOptionalCount(value: unknown): number | null {
  const count = parseCount(value)
  return count > 0 ? count : count === 0 ? 0 : null
}

function parseAbbreviatedCount(value: string): number | null {
  const raw = value.trim().toUpperCase().replace(/,/g, '')
  const match = raw.match(/^(\d+(?:\.\d+)?)([KMB])?$/)
  if (!match) {
    const numeric = Number(raw)
    return Number.isFinite(numeric) ? Math.round(numeric) : null
  }

  const base = Number(match[1])
  const suffix = match[2]

  if (!suffix) return Math.round(base)
  if (suffix === 'K') return Math.round(base * 1_000)
  if (suffix === 'M') return Math.round(base * 1_000_000)
  if (suffix === 'B') return Math.round(base * 1_000_000_000)

  return Math.round(base)
}
