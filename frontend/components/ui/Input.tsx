"use client";
import { InputHTMLAttributes, forwardRef } from "react";
import { cn } from "@/utils";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, label, error, id, ...props }, ref) => {
    return (
      <div className="space-y-1">
        {label && (
          <label htmlFor={id} className="block text-sm font-medium text-text">
            {label}
          </label>
        )}
        <input
          ref={ref}
          id={id}
          className={cn(
            "block w-full rounded-2xl border border-border px-4 py-2.5 text-sm shadow-sm placeholder-text-secondary/60 focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary bg-surface",
            error && "border-danger focus:border-danger focus:ring-danger",
            className
          )}
          {...props}
        />
        {error && <p className="text-xs text-danger mt-1">{error}</p>}
      </div>
    );
  }
);
Input.displayName = "Input";
