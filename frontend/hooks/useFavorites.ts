"use client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { favoriteService } from "@/services/favorites";

export function useFavorites() {
  return useQuery({
    queryKey: ["favorites"],
    queryFn: favoriteService.list,
  });
}

export function useAddFavorite() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: favoriteService.add,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["favorites"] });
      queryClient.invalidateQueries({ queryKey: ["doctor"] });
    },
  });
}

export function useRemoveFavorite() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: favoriteService.remove,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["favorites"] });
      queryClient.invalidateQueries({ queryKey: ["doctor"] });
    },
  });
}
