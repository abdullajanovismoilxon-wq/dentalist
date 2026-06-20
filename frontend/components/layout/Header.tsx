"use client";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useAuthStore } from "@/stores/authStore";
import { Bell, Search, LogOut, Settings, Stethoscope } from "lucide-react";
import { useUnreadCount } from "@/hooks/useNotifications";

export function Header() {
  const user = useAuthStore((s) => s.user);
  const logout = useAuthStore((s) => s.logout);
  const { data: unreadCount } = useUnreadCount();
  const [showMenu, setShowMenu] = useState(false);
  const [mounted, setMounted] = useState(false);
  const router = useRouter();
  const [searchVal, setSearchVal] = useState("");

  useEffect(() => { setMounted(true); }, []);

  if (!mounted) {
    return (
      <header className="sticky top-0 z-40 bg-white border-b border-border">
        <div className="flex items-center justify-between px-4 h-14 max-w-7xl mx-auto">
          <div className="flex items-center gap-2">
            <Stethoscope className="w-6 h-6 text-primary" />
            <span className="text-lg font-bold text-primary">Dentalist</span>
          </div>
        </div>
      </header>
    );
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchVal.trim()) {
      router.push(`/search?q=${encodeURIComponent(searchVal.trim())}`);
      setSearchVal("");
    }
  };

  if (!user) {
    return (
      <header className="sticky top-0 z-40 bg-white border-b border-border">
        <div className="flex items-center justify-between px-4 h-14 max-w-7xl mx-auto">
          <Link href="/" className="flex items-center gap-2">
            <Stethoscope className="w-6 h-6 text-primary" />
            <span className="text-lg font-bold text-primary">Dentalist</span>
          </Link>
          <div className="flex items-center gap-2">
            <Link href="/auth/login" className="px-3 py-1.5 text-sm text-primary font-medium">Kirish</Link>
            <Link href="/auth/register" className="px-3 py-1.5 text-sm bg-primary text-white rounded-full font-medium">Ro'yxat</Link>
          </div>
        </div>
      </header>
    );
  }

  return (
    <header className="sticky top-0 z-40 bg-white border-b border-border">
      <div className="px-4 py-3 max-w-7xl mx-auto space-y-3">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-text-secondary">Xush kelibsiz</p>
            <h1 className="text-base font-bold">{user.first_name || user.username}</h1>
          </div>
          <div className="flex items-center gap-1">
            <Link href="/notifications" className="relative p-2 hover:bg-bg rounded-xl transition-colors">
              <Bell className="w-5 h-5 text-text-secondary" />
              {unreadCount && unreadCount > 0 && (
                <span className="absolute top-1 right-1 w-2 h-2 bg-danger rounded-full" />
              )}
            </Link>
            <div className="relative">
              <button onClick={() => setShowMenu(!showMenu)} className="p-2 hover:bg-bg rounded-xl transition-colors">
                <Settings className="w-5 h-5 text-text-secondary" />
              </button>
              {showMenu && (
                <>
                  <div className="fixed inset-0 z-10" onClick={() => setShowMenu(false)} />
                  <div className="absolute right-0 top-full mt-1 z-20 bg-white border border-border rounded-2xl shadow-lg py-1 min-w-[180px]">
                    <Link href="/profile" className="flex items-center gap-2 px-4 py-2.5 text-sm hover:bg-bg" onClick={() => setShowMenu(false)}>Profil</Link>
                    {user.role === "doctor" && (
                      <Link href="/dashboard" className="flex items-center gap-2 px-4 py-2.5 text-sm hover:bg-bg" onClick={() => setShowMenu(false)}>Boshqaruv paneli</Link>
                    )}
                    <hr className="border-border my-1" />
                    <button onClick={() => { logout(); setShowMenu(false); }} className="flex items-center gap-2 w-full px-4 py-2.5 text-sm text-danger hover:bg-bg">
                      <LogOut className="w-4 h-4" /> Chiqish
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>

        <form onSubmit={handleSearch} className="relative">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-text-secondary" />
          <input
            type="text"
            value={searchVal}
            onChange={(e) => setSearchVal(e.target.value)}
            placeholder="Shifokor, klinika yoki mutaxassislik"
            className="w-full h-10 pl-10 pr-4 bg-bg border border-border rounded-2xl text-sm placeholder:text-text-secondary outline-none focus:border-primary transition-colors"
          />
        </form>
      </div>
    </header>
  );
}
