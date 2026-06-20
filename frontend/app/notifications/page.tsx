"use client";
import { useNotifications, useMarkNotificationRead, useMarkAllNotificationsRead } from "@/hooks/useNotifications";
import { Card, CardContent } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Bell, CheckCheck, MessageCircle, Calendar } from "lucide-react";
import Link from "next/link";
import { formatDate } from "@/utils";

const icons: Record<string, React.ReactNode> = {
  new_message: <MessageCircle className="w-5 h-5 text-primary" />,
  appointment_booked: <Calendar className="w-5 h-5 text-success" />,
  appointment_confirmed: <Calendar className="w-5 h-5 text-success" />,
  appointment_cancelled: <Calendar className="w-5 h-5 text-danger" />,
};

export default function NotificationsPage() {
  const { data: notifications, isLoading } = useNotifications();
  const markRead = useMarkNotificationRead();
  const markAllRead = useMarkAllNotificationsRead();

  return (
    <div className="max-w-2xl mx-auto px-4 pt-4 pb-4 space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-lg font-bold">Bildirishnomalar</h1>
        {notifications?.some((n) => !n.is_read) && (
          <Button variant="ghost" size="sm" onClick={() => markAllRead.mutate()}>
            <CheckCheck className="w-4 h-4 mr-1" /> Barchasi o'qildi
          </Button>
        )}
      </div>

      {isLoading ? (
        <div className="space-y-2">
          {[1, 2, 3].map((i) => (
            <div key={i} className="bg-surface rounded-2xl border border-border p-4 animate-pulse flex gap-3">
              <div className="w-10 h-10 rounded-xl bg-gray-200" />
              <div className="flex-1 space-y-2">
                <div className="h-4 bg-gray-200 rounded w-1/3" />
                <div className="h-3 bg-gray-200 rounded w-2/3" />
              </div>
            </div>
          ))}
        </div>
      ) : !notifications?.length ? (
        <div className="flex flex-col items-center justify-center py-16 text-text-secondary">
          <Bell className="w-12 h-12 mb-3 opacity-30" />
          <p className="text-sm">Bildirishnomalar yo'q</p>
        </div>
      ) : (
        <div className="space-y-2">
          {notifications.map((notif) => (
            <Card key={notif.id} className={notif.is_read ? "" : "border-primary/20 bg-primary-light/30"}>
              <CardContent
                className="p-4 flex gap-3 cursor-pointer"
                onClick={() => !notif.is_read && markRead.mutate(notif.id)}
              >
                <div className="flex-shrink-0 mt-1">{icons[notif.type] || <Bell className="w-5 h-5 text-text-secondary" />}</div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-medium text-sm">{notif.title}</h3>
                  <p className="text-xs text-text-secondary mt-0.5">{notif.message}</p>
                  <p className="text-[10px] text-text-secondary mt-1">{formatDate(notif.created_at)}</p>
                </div>
                {!notif.is_read && <div className="w-2 h-2 rounded-full bg-primary flex-shrink-0 mt-2" />}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
