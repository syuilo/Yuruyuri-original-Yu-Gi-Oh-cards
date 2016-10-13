--古谷向日葵
--①：自分フィールド上に「大室櫻子」が表側表示で存在する場合、このカードは手札から特殊召喚できる。
--②：このカードが召喚・特殊召喚に成功した時、自分は３００ＬＰ回復する。
--③：1ターンに1度だけ、相手の魔法・罠カードの発動を無効にし破壊する。その後相手はデッキからカードを１枚ドローする。
--④：このカードが相手によって破壊された時、デッキから「大室櫻子」1人を特殊召喚できる。

function c1080.initial_effect(c)

	-- special summon
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1080, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1080.e1condition)
	c:RegisterEffect(e1)

	-- recover
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1080, 1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetTarget(c1080.e2target)
	e2:SetOperation(c1080.e2operation)
	c:RegisterEffect(e2)
	local e2c = e2:Clone()
	e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2c)

	--Activate
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1080, 2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c1080.e3condition)
	e3:SetTarget(c1080.e3target)
	e3:SetOperation(c1080.e3operation)
	c:RegisterEffect(e3)

	-- special summon
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1080, 3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c1080.e4condition)
	e4:SetTarget(c1080.e4target)
	e4:SetOperation(c1080.e4operation)
	c:RegisterEffect(e4)

end

-- 櫻子フィルター
function c1080.e1spfilter(c)
	-- 表側表示(=IsFaceup)かつ櫻子(=1050)か
	return c:IsFaceup() and c:IsCode(1050)
end

function c1080.e1condition(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(c1080.e1spfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil)
end

function c1080.e2target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(300)
	Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 300)
end

function c1080.e2operation(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
	Duel.Recover(p, d, REASON_EFFECT)
end

function c1080.e3condition(e, tp, eg, ep, ev, re, r, rp)
	-- re:IsHasType(EFFECT_TYPE_ACTIVATE) を無くすと効果モンスターの効果も対象になります
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp ~= tp and Duel.IsChainNegatable(ev)
end

function c1080.e3target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsPlayerCanDraw(1 - tp, 1) end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
	end
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, 1 - tp, 1)
end

function c1080.e3operation(e, tp, eg, ep, ev, re, r, rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg, REASON_EFFECT)
	end
	Duel.Draw(1 - tp, 1, REASON_EFFECT)
end

function c1080.e4condition(e, tp, eg, ep, ev, re, r, rp)
	return rp ~= tp and e:GetHandler():GetPreviousControler() == tp
end

function c1080.e4filter(c, e, tp)
	return c:IsCode(1050) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function c1080.e4target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and c1080.e4filter(chkc, e, tp) end
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingTarget(c1080.e4filter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp,c1080.e4filter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function c1080.e4operation(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
	end
end
