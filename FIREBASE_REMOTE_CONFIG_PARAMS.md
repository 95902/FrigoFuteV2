# Firebase Remote Config - Paramètres FrigoFute

## 10 Paramètres à configurer

### 1. enable_beta_features
- **Type**: Boolean
- **Valeur**: true
- **Description**: Features beta

### 2. enable_meal_planning
- **Type**: Boolean
- **Valeur**: false
- **Description**: Epic 9

### 3. enable_ai_nutrition_coach
- **Type**: Boolean
- **Valeur**: false
- **Description**: Epic 11

### 4. enable_price_comparison
- **Type**: Boolean
- **Valeur**: false
- **Description**: Epic 12

### 5. enable_gamification
- **Type**: Boolean
- **Valeur**: false
- **Description**: Epic 13

### 6. max_free_ocr_scans
- **Type**: Number
- **Valeur**: 10
- **Description**: Limite gratuite

### 7. max_premium_ocr_scans
- **Type**: Number
- **Valeur**: 1000
- **Description**: Limite premium

### 8. gemini_rate_limit_seconds
- **Type**: Number
- **Valeur**: 2
- **Description**: Rate limiting

### 9. vision_api_monthly_quota
- **Type**: Number
- **Valeur**: 1000
- **Description**: Quota mensuel

### 10. enable_offline_mode
- **Type**: Boolean
- **Valeur**: true
- **Description**: Offline-first

---

## Instructions Console Firebase

Pour chaque paramètre ci-dessus :

1. Cliquez sur "Add parameter" (Ajouter un paramètre)
2. Copiez le nom du paramètre dans "Parameter key"
3. Sélectionnez le type (Boolean ou Number)
4. Entrez la valeur par défaut
5. (Optionnel) Ajoutez la description
6. Cliquez "Save"

Une fois tous les 10 paramètres ajoutés → Cliquez "Publish changes"
