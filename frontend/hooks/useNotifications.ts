"use client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { notificationService } from "@/services/notifications";

export function useNotifications() {
  return useQuery({
    queryKey: ["notifications"],
    queryFn: notificationService.list,
    refetchInterval: 30000,
  });
}

export function useUnreadCount() {
  return useQuery({
    queryKey: ["notifications", "unread"],
    queryFn: notificationService.unreadCount,
    refetchInterval: 15000,
  });
}

export function useMarkNotificationRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: notificationService.markRead,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notifications"] });
      queryClient.invalidateQueries({ queryKey: ["notifications", "unread"] });
    },
  });
}

export function useMarkAllNotificationsRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: notificationService.markAllRead,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notifications"] });
      queryClient.invalidateQueries({ queryKey: ["notifications", "unread"] });
    },
  });
}
