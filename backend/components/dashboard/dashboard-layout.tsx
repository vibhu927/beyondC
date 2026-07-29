'use client'

import Sidebar from './sidebar'
import Topbar from './topbar'
import MobileNav from './mobile-nav'
import { SidebarProvider, useSidebar } from './sidebar-context'
import { ThemeProvider } from './theme-context'

function LayoutInner({ children }: { children: React.ReactNode }) {
  const { collapsed } = useSidebar()

  return (
    <div className="min-h-screen bg-[#F6F5F1] dark:bg-[#0f0f1a] transition-colors duration-200">
      <Sidebar />
      <Topbar />
      <main
        className={`transition-all duration-200 pt-16 pb-20 lg:pb-8 px-4 sm:px-6 lg:px-8 ${
          collapsed ? 'lg:ml-20' : 'lg:ml-64'
        }`}
      >
        {children}
      </main>
      <MobileNav />
    </div>
  )
}

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <ThemeProvider>
      <SidebarProvider>
        <LayoutInner>{children}</LayoutInner>
      </SidebarProvider>
    </ThemeProvider>
  )
}
