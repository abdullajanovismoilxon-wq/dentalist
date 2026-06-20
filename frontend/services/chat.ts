import api from "./api";
import type { ChatRoom, Message } from "@/types";

export const chatService = {
  async myRooms(): Promise<ChatRoom[]> {
    const res = await api.get("/chat/rooms/");
    return res.data.results || res.data;
  },

  async getOrCreateRoom(doctorId: number): Promise<ChatRoom> {
    const res = await api.post("/chat/rooms/get-or-create/", { doctor: doctorId });
    return res.data;
  },

  async getMessages(roomId: number): Promise<Message[]> {
    const res = await api.get(`/chat/rooms/${roomId}/messages/`);
    return res.data.results || res.data;
  },

  async sendMessage(roomId: number, text: string): Promise<Message> {
    const res = await api.post(`/chat/rooms/${roomId}/send/`, { text });
    return res.data;
  },
};
