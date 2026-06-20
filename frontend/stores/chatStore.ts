import { create } from "zustand";
import type { ChatRoom, Message } from "@/types";

interface ChatState {
  rooms: ChatRoom[];
  activeRoom: ChatRoom | null;
  messages: Record<number, Message[]>;
  setRooms: (rooms: ChatRoom[]) => void;
  setActiveRoom: (room: ChatRoom | null) => void;
  setMessages: (roomId: number, messages: Message[]) => void;
  addMessage: (roomId: number, message: Message) => void;
  updateLastMessage: (roomId: number, message: Message) => void;
}

export const useChatStore = create<ChatState>((set, get) => ({
  rooms: [],
  activeRoom: null,
  messages: {},

  setRooms: (rooms) => set({ rooms }),

  setActiveRoom: (room) => set({ activeRoom: room }),

  setMessages: (roomId, messages) =>
    set((state) => ({ messages: { ...state.messages, [roomId]: messages } })),

  addMessage: (roomId, message) =>
    set((state) => ({
      messages: {
        ...state.messages,
        [roomId]: [...(state.messages[roomId] || []), message],
      },
    })),

  updateLastMessage: (roomId, message) =>
    set((state) => ({
      rooms: state.rooms.map((r) =>
        r.id === roomId
          ? {
              ...r,
              last_message: {
                text: message.text,
                sender: message.sender,
                created_at: message.created_at,
              },
            }
          : r
      ),
    })),
}));
