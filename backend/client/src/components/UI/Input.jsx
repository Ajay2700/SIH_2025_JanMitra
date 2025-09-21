import React, { forwardRef } from 'react'

const Input = forwardRef(({ 
  label, 
  error, 
  helperText, 
  leftIcon, 
  rightIcon, 
  size = 'md', 
  className = '', 
  required = false,
  ...props 
}, ref) => {
  const baseClasses = 'block w-full border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200'
  
  const sizes = {
    sm: 'px-3 py-2 text-sm',
    md: 'px-3 py-3 text-sm',
    lg: 'px-4 py-3 text-base'
  }
  
  const paddingClasses = {
    sm: leftIcon ? 'pl-10' : 'pl-3',
    md: leftIcon ? 'pl-10' : 'pl-3',
    lg: leftIcon ? 'pl-12' : 'pl-4'
  }
  
  const rightPaddingClasses = {
    sm: rightIcon ? 'pr-10' : 'pr-3',
    md: rightIcon ? 'pr-10' : 'pr-3',
    lg: rightIcon ? 'pr-12' : 'pr-4'
  }
  
  const iconSizes = {
    sm: 'h-4 w-4',
    md: 'h-5 w-5',
    lg: 'h-6 w-6'
  }
  
  const iconPositions = {
    sm: 'pl-3',
    md: 'pl-3',
    lg: 'pl-4'
  }
  
  return (
    <div className="space-y-1">
      {label && (
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
      )}
      
      <div className="relative">
        {leftIcon && (
          <div className={`absolute inset-y-0 left-0 ${iconPositions[size]} flex items-center pointer-events-none`}>
            <span className={`${iconSizes[size]} text-gray-400`}>
              {leftIcon}
            </span>
          </div>
        )}
        
        <input
          ref={ref}
          className={`${baseClasses} ${sizes[size]} ${paddingClasses[size]} ${rightPaddingClasses[size]} ${error ? 'border-red-300 dark:border-red-600 focus:ring-red-500 focus:border-red-500' : ''} ${className}`}
          {...props}
        />
        
        {rightIcon && (
          <div className={`absolute inset-y-0 right-0 ${iconPositions[size]} flex items-center pointer-events-none`}>
            <span className={`${iconSizes[size]} text-gray-400`}>
              {rightIcon}
            </span>
          </div>
        )}
      </div>
      
      {error && (
        <p className="text-sm text-red-600 dark:text-red-400 flex items-center">
          <svg className="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          {error}
        </p>
      )}
      
      {helperText && !error && (
        <p className="text-sm text-gray-500 dark:text-gray-400">{helperText}</p>
      )}
    </div>
  )
})

Input.displayName = 'Input'

export default Input
