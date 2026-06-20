"use client";
import { useChatRooms } from "@/hooks/useChat";
import { useAuthStore } from "@/stores/authStore";
import { Card, CardContent } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { MessageCircle, User, ChevronRight } from "lucide-react";
import Link from "next/link";

export default function ChatListPage() {
  const { data: rooms, isLoading } = useChatRooms();
  const user = useAuthStore((s) => s.user);

  if (!user) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] px-4">
        <MessageCircle className="w-16 h-16 text-text-secondary/30 mb-4" />
        <p className="text-text-secondary mb-4">Chatni ko'rish uchun kiring</p>
        <Link href="/auth/login"><Button>Kirish</Button></Link>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto px-4 pt-4 pb-4 space-y-4">
      <h1 className="text-lg font-bold">Xabarlar</h1>

      {isLoading ? (
        <div className="space-y-2">
          {[1, 2].map((i) => (
            <div key={i} className="bg-surface rounded-2xl border border-border p-4 animate-pulse flex gap-3">
              <div className="w-12 h-12 rounded-2xl bg-gray-200" />
              <div className="flex-1 space-y-2">
                <div className="h-4 bg-gray-200 rounded w-1/3" />
                <div className="h-3 bg-gray-200 rounded w-2/3" />
              </div>
            </div>
          ))}
        </div>
      ) : !rooms?.length ? (
        <div className="flex flex-col items-center justify-center py-16 text-text-secondary">
          <MessageCircle className="w-12 h-12 mb-3 opacity-30" />
          <p className="text-sm">Xabarlar yo'q</p>
          <Link href="/" className="text-primary text-sm mt-2 font-medium">Shifokor qidirish</Link>
        </div>
      ) : (
        <div className="space-y-2">
          {rooms.map((room) => {
            const otherName = user.role === "doctor"
              ? `${room.patient_detail?.first_name || ""} ${room.patient_detail?.last_name || ""}`.trim() || "Bemor"
              : room.doctor_detail?.full_name || "Shifokor";
            return (
              <Link key={room.id} href={`/chat/${room.id}`}>
                <Card hover>
                  <CardContent className="p-4">
                    <div className="flex items-center gap-3">
                      <div className="w-12 h-12 rounded-2xl bg-primary-light flex items-center justify-center flex-shrink-0">
                        <User className="w-6 h-6 text-primary" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between">
                          <h3 className="font-semibold text-sm truncate">{otherName}</h3>
                          <ChevronRight className="w-4 h-4 text-text-secondary flex-shrink-0" />
                        </div>
                        {room.last_message && (
                          <p className="text-xs text-text-secondary truncate mt-0.5">{room.last_message.text}</p>
                        )}
                      </div>
                      {room.unread_count > 0 && (
                        <span className="bg-primary text-white text-[10px] font-bold rounded-full w-5 h-5 flex items-center justify-center flex-shrink-0">
                          {room.unread_count}
                        </span>
                      )}
                    </div>
                  </CardContent>
                </Card>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
