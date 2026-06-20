import api from "./api";
import type { Notification } from "@/types";

export const notificationService = {
  async list(): Promise<Notification[]> {
    const res = await api.get("/notifications/");
    return res.data.results || res.data;
  },

  async markRead(id: number): Promise<Notification> {
    const res = await api.patch(`/notifications/${id}/read/`);
    return res.data;
  },

  async markAllRead(): Promise<void> {
    await api.patch("/notifications/mark-all-read/");
  },

  async unreadCount(): Promise<number> {
    const res = await api.get("/notifications/unread-count/");
    return res.data.unread_count;
  },
};
