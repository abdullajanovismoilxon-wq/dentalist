"use client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { chatService } from "@/services/chat";

export function useChatRooms() {
  return useQuery({
    queryKey: ["chat-rooms"],
    queryFn: chatService.myRooms,
    refetchInterval: 10000,
  });
}

export function useChatMessages(roomId: number) {
  return useQuery({
    queryKey: ["chat-messages", roomId],
    queryFn: () => chatService.getMessages(roomId),
    enabled: !!roomId,
    refetchInterval: 5000,
  });
}

export function useGetOrCreateRoom() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: chatService.getOrCreateRoom,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["chat-rooms"] }),
  });
}

export function useSendMessage() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ roomId, text }: { roomId: number; text: string }) =>
      chatService.sendMessage(roomId, text),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ["chat-messages", variables.roomId] });
      queryClient.invalidateQueries({ queryKey: ["chat-rooms"] });
    },
  });
}
