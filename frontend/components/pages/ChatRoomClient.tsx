"use client";
import { useState, useRef, useEffect } from "react";
import { useParams, useRouter } from "next/navigation";
import { useChatMessages } from "@/hooks/useChat";
import { useAuthStore } from "@/stores/authStore";
import { Button } from "@/components/ui/Button";
import { Send, ChevronLeft, User } from "lucide-react";

export default function ChatRoomClient() {
  const { id } = useParams<{ id: string }>();
  const roomId = parseInt(id);
  const user = useAuthStore((s) => s.user);
  const { data: messages, isLoading } = useChatMessages(roomId);
  const [text, setText] = useState("");
  const [ws, setWs] = useState<WebSocket | null>(null);
  const [liveMessages, setLiveMessages] = useState<Array<{ id: number; sender: number; text: string; created_at: string }>>([]);
  const bottomRef = useRef<HTMLDivElement>(null);
  const router = useRouter();

  useEffect(() => {
    let token = "";
    if (typeof window !== "undefined") {
      const raw = localStorage.getItem("auth_tokens");
      if (raw) {
        try { token = "?token=" + JSON.parse(raw).access; } catch { /* ignore */ }
      }
    }
    const socket = new WebSocket(`${process.env.NEXT_PUBLIC_WS_URL || "ws://localhost:8000/ws"}/chat/${roomId}/${token}`);
    socket.onopen = () => {};
    socket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.type === "chat_message") {
        setLiveMessages((prev) => [...prev, data]);
      }
    };
    setWs(socket);
    return () => socket.close();
  }, [roomId]);

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior: "smooth" }); }, [messages, liveMessages]);

  const sendMessage = () => {
    if (!text.trim() || !ws) return;
    ws.send(JSON.stringify({ type: "send_message", text: text.trim() }));
    setText("");
  };

  const allMessages = [...(messages || []), ...liveMessages.filter((m) => !messages?.some((om) => om.id === m.id))];

  if (!user) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] px-4">
        <User className="w-16 h-16 text-text-secondary/30 mb-4" />
        <p className="text-text-secondary">Kiring va chatni boshlang</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-[calc(100dvh-3.5rem)] max-w-2xl mx-auto">
      <div className="flex items-center gap-2 px-4 py-3 border-b border-border bg-surface">
        <button onClick={() => router.back()} className="p-1 -ml-1">
          <ChevronLeft className="w-5 h-5" />
        </button>
        <h1 className="font-semibold text-sm">Chat</h1>
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3">
        {isLoading ? (
          <div className="space-y-3">
            {[1, 2].map((i) => (
              <div key={i} className="flex gap-3 animate-pulse">
                <div className="w-8 h-8 rounded-2xl bg-gray-200" />
                <div className="h-10 bg-gray-200 rounded-2xl w-2/3" />
              </div>
            ))}
          </div>
        ) : allMessages.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-text-secondary">
            <User className="w-12 h-12 mb-3 opacity-30" />
            <p className="text-sm">Xabarlar yo'q</p>
          </div>
        ) : (
          allMessages.map((msg, i) => {
            const isMine = msg.sender === user.id;
            return (
              <div key={msg.id || i} className={`flex ${isMine ? "justify-end" : "justify-start"}`}>
                <div className={`max-w-[80%] px-4 py-2.5 rounded-2xl text-sm ${
                  isMine
                    ? "bg-primary text-white rounded-br-md"
                    : "bg-surface border border-border rounded-bl-md"
                }`}>
                  <p>{msg.text}</p>
                  <p className={`text-[10px] mt-1 ${isMine ? "text-white/60" : "text-text-secondary"}`}>
                    {new Date(msg.created_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
                  </p>
                </div>
              </div>
            );
          })
        )}
        <div ref={bottomRef} />
      </div>

      <div className="px-4 py-3 border-t border-border bg-surface">
        <div className="flex gap-2">
          <input
            type="text"
            value={text}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && sendMessage()}
            placeholder="Xabar yozing..."
            className="flex-1 rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary"
          />
          <Button onClick={sendMessage} disabled={!text.trim()} className="w-11 h-11 p-0 flex items-center justify-center rounded-2xl">
            <Send className="w-4 h-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}
