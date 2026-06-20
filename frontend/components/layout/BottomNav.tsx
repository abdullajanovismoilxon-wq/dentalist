"use client";
import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuthStore } from "@/stores/authStore";
import { useUnreadCount } from "@/hooks/useNotifications";
import { Home, MapPin, Calendar, MessageCircle, User, Bell } from "lucide-react";

const patientTabs = [
  { href: "/", label: "Asosiy", icon: Home },
  { href: "/nearby", label: "Atrof", icon: MapPin },
  { href: "/appointments", label: "Qabul", icon: Calendar },
  { href: "/chat", label: "Chat", icon: MessageCircle },
  { href: "/profile", label: "Profil", icon: User },
];

const doctorTabs = [
  { href: "/dashboard", label: "Boshqaruv", icon: Home },
  { href: "/appointments", label: "Qabullar", icon: Calendar },
  { href: "/chat", label: "Chat", icon: MessageCircle },
  { href: "/notifications", label: "Bildirish", icon: Bell },
  { href: "/profile", label: "Profil", icon: User },
];

export function BottomNav() {
  const [mounted, setMounted] = useState(false);
  useEffect(() => { setMounted(true); }, []);
  const pathname = usePathname();
  const user = useAuthStore((s) => s.user);
  const { data: unreadCount } = useUnreadCount();

  if (!mounted || !user) return null;

  const tabs = user.role === "doctor" ? doctorTabs : patientTabs;

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-border pb-[env(safe-area-inset-bottom,0px)]">
      <div className="flex items-center justify-around h-16 max-w-lg mx-auto">
        {tabs.map((tab) => {
          const isActive = pathname === tab.href || (tab.href !== "/" && pathname.startsWith(tab.href));
          const isChat = tab.href === "/chat";
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex flex-col items-center justify-center flex-1 h-full gap-0.5 transition-colors ${
                isActive ? "text-primary" : "text-text-secondary"
              }`}
            >
              <div className="relative">
                <tab.icon className="w-5 h-5" />
                {isChat && unreadCount && unreadCount > 0 && (
                  <span className="absolute -top-1.5 -right-1.5 bg-danger text-white text-[10px] font-bold rounded-full w-4 h-4 flex items-center justify-center">
                    {unreadCount > 9 ? "9+" : unreadCount}
                  </span>
                )}
              </div>
              <span className="text-[10px] font-medium">{tab.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
