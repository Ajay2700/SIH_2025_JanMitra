import React from 'react'

const Card = ({ 
  children, 
  title, 
  subtitle, 
  header, 
  footer, 
  variant = 'default',
  padding = 'md',
  className = '',
  ...props 
}) => {
  const baseClasses = 'bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 shadow-sm'
  
  const variants = {
    default: 'shadow-sm',
    elevated: 'shadow-lg hover:shadow-xl transition-shadow duration-200',
    outlined: 'shadow-none border-2',
    flat: 'shadow-none border-0'
  }
  
  const paddingClasses = {
    none: '',
    sm: 'p-4',
    md: 'p-6',
    lg: 'p-8',
    xl: 'p-10'
  }
  
  return (
    <div className={`${baseClasses} ${variants[variant]} ${className}`} {...props}>
      {header && (
        <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
          {header}
        </div>
      )}
      
      {(title || subtitle) && !header && (
        <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
          {title && (
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              {title}
            </h3>
          )}
          {subtitle && (
            <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
              {subtitle}
            </p>
          )}
        </div>
      )}
      
      <div className={paddingClasses[padding]}>
        {children}
      </div>
      
      {footer && (
        <div className="px-6 py-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 rounded-b-lg">
          {footer}
        </div>
      )}
    </div>
  )
}

export default Card
