"use client";
import { ButtonHTMLAttributes, forwardRef } from "react";
import { cn } from "@/utils";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "outline" | "ghost" | "danger";
  size?: "sm" | "md" | "lg";
  loading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "primary", size = "md", loading, children, disabled, ...props }, ref) => {
    return (
      <button
        ref={ref}
        disabled={disabled || loading}
        className={cn(
          "inline-flex items-center justify-center font-medium rounded-2xl transition-all focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed",
          {
            "bg-primary text-white hover:bg-primary-dark active:scale-[0.98]": variant === "primary",
            "bg-bg text-text hover:bg-border active:scale-[0.98]": variant === "secondary",
            "border border-border text-text hover:bg-bg active:scale-[0.98]": variant === "outline",
            "text-text-secondary hover:bg-bg": variant === "ghost",
            "bg-danger text-white hover:bg-red-700 active:scale-[0.98]": variant === "danger",
          },
          {
            "px-3 py-1.5 text-xs": size === "sm",
            "px-5 py-2.5 text-sm": size === "md",
            "px-6 py-3 text-base": size === "lg",
          },
          className
        )}
        {...props}
      >
        {loading ? (
          <svg className="animate-spin -ml-1 mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
          </svg>
        ) : null}
        {children}
      </button>
    );
  }
);
Button.displayName = "Button";
